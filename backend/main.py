from fastapi import FastAPI, UploadFile, File
import torch
import torchvision.transforms as transforms
from PIL import Image
import io
import os

app = FastAPI()

# Configuration
MODEL_PATH = "best_waste_model.pth"
CLASSES = [
    "Battery", "Biological", "Brown-glass", "Cardboard", "Clothes", 
    "Green-glass", "Metal", "Paper", "Plastic", "Shoes", "Trash", "White-glass"
] # Placeholder: Replace with your actual 12 classes if different

# Load Model
model = None
from torchvision.models import mobilenet_v3_large, mobilenet_v3_small

try:
    if os.path.exists(MODEL_PATH):
        try:
            # 1. Try loading as full model (old way)
            model = torch.load(MODEL_PATH, map_location=torch.device('cpu'))
            if isinstance(model, dict):
                raise AttributeError("Is a state_dict")
            model.eval()
            print(f"Model loaded as Full Model from {MODEL_PATH}")
        except Exception:
            print("Model is likely a state_dict. Attempting to load into architecture...")
            state_dict = torch.load(MODEL_PATH, map_location=torch.device('cpu'))
            
            # 2. Try MobileNetV3 Large (12 classes)
            try:
                model = mobilenet_v3_large(weights=None)
                # Recreate classifier head for 12 classes (assuming standard transfer learning)
                in_features = model.classifier[3].in_features
                model.classifier[3] = torch.nn.Linear(in_features, 12)
                model.load_state_dict(state_dict)
                print("Model loaded as MobileNetV3 Large")
            except Exception as e_large:
                print(f"Not MobileNetV3 Large: {e_large}")
                # 3. Try MobileNetV3 Small (12 classes)
                try:
                    model = mobilenet_v3_small(weights=None)
                    in_features = model.classifier[3].in_features
                    model.classifier[3] = torch.nn.Linear(in_features, 12)
                    model.load_state_dict(state_dict)
                    print("Model loaded as MobileNetV3 Small")
                except Exception as e_small:
                    print(f"Not MobileNetV3 Small: {e_small}")
                    raise RuntimeError("Could not load state_dict into MobileNetV3 Large or Small.")
            
            model.eval()
    else:
        print(f"WARNING: Model file not found at {MODEL_PATH}. Prediction endpoint will fail.")
except Exception as e:
    print(f"ERROR: Failed to load model: {e}")

# Preprocessing
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

@app.get("/")
def read_root():
    return {"message": "Waste Classification API is running"}

@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):
    if model is None:
        return {"error": "Model not loaded. Please ensure .pth file is in the backend directory."}

    try:
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data)).convert('RGB')
        
        # Transform and add batch dimension
        tensor = transform(image).unsqueeze(0)
        
        with torch.no_grad():
            outputs = model(tensor)
            probabilities = torch.nn.functional.softmax(outputs, dim=1)
            confidence, predicted = torch.max(probabilities, 1)
            
            p_val = predicted.item()
            conf_val = confidence.item()
        
        return {
            "class": CLASSES[p_val] if p_val < len(CLASSES) else "Unknown",
            "class_id": p_val,
            "confidence": float(conf_val)
        }
    except Exception as e:
        return {"error": str(e)}

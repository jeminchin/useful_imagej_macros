import numpy as np
from skimage import measure
from roifile import ImagejRoi
import zipfile
import os

# Automatically find the labels layer
labels_layer = None
for layer in viewer.layers:
    if 'Labels' in str(type(layer)):
        labels_layer = layer
        break

if labels_layer is None:
    print("ERROR: No labels layer found!")
    print("Available layers:", [layer.name for layer in viewer.layers])
else:
    labels = labels_layer.data
    layer_name = labels_layer.name
    
    print(f"Found labels layer: {layer_name}")
    print(f"Processing {len(np.unique(labels)) - 1} cells...")
    
    # Set your base path here
    base_path = r'C:\....'
    
    # Create output filename from layer name
    filename = layer_name.replace('_samcell_labels', '').replace('_labels', '')
    
    # Get all cell regions
    regions = measure.regionprops(labels)
    roi_files = []
    
    for i, region in enumerate(regions):
        contours = measure.find_contours(labels == region.label, 0.5)
        if len(contours) > 0:
            coords = contours[0]
            coords_ij = np.column_stack([coords[:, 1], coords[:, 0]])
            roi = ImagejRoi.frompoints(coords_ij)
            roi_path = os.path.join(base_path, f'cell_{region.label}.roi')
            roi.tofile(roi_path)
            roi_files.append(roi_path)
    
    # Create zip file
    zip_path = os.path.join(base_path, f'{filename}_RoiSet.zip')
    with zipfile.ZipFile(zip_path, 'w') as zipf:
        for roi_file in roi_files:
            zipf.write(roi_file, os.path.basename(roi_file))
            os.remove(roi_file)
    
    print(f"✓ Saved {len(roi_files)} ROIs to {zip_path}")

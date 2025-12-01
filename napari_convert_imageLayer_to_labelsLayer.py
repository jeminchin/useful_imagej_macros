viewer.layers

# Get the mask data
masks = viewer.layers['your_mask_layer_name'].data

# Remove the image layer
viewer.layers.remove('your_mask_layer_name')

# Add as labels layer
viewer.add_labels(masks, name='your_desired_labels_name')

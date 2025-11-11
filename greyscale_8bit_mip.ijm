// ----- Get list of all open images -----
originalImages = getList("image.titles");
numImages = originalImages.length;

print("Found " + numImages + " images to process");

// ----- Process each image -----
for (j = 0; j < numImages; j++) {
    imageName = originalImages[j];
    
    selectWindow(imageName);
    print("Processing " + (j+1) + "/" + numImages + ": " + imageName);
    
    // ----- Get image info and directory -----
    origTitle = getTitle();
    dir = getDirectory("image");
    
    // If directory is empty/null, ask user to choose one
    if (dir == "" || dir == "none") {
        dir = getDirectory("Choose save directory for: " + origTitle);
    }
    
    // Create clean basename
    baseName = origTitle;
    dotIndex = lastIndexOf(baseName, ".");
    if (dotIndex > -1) {
        baseName = substring(baseName, 0, dotIndex);
    }
    baseName = replace(baseName, " - ", "_");
    baseName = replace(baseName, " ", "_");
    baseName = replace(baseName, "/", "_");
    baseName = replace(baseName, "\\", "_");
    baseName = replace(baseName, ":", "_");
    
    // Get dimensions BEFORE conversion
    getDimensions(width, height, channels, slices, frames);
    print("  Slices: " + slices);
    
    // ----- Convert to grayscale -----
    run("Grays");
    
    // ----- Convert to 8-bit -----
    setOption("ScaleConversions", true);
    run("8-bit");
    
    // ----- Run Max Projection if z-stack -----
    if (slices > 1) {
        print("  Running Max Projection...");
        run("Z Project...", "projection=[Max Intensity]");
        
        // The projection creates a new window with "MAX_" prefix
        maxTitle = "MAX_" + origTitle;
        
        // Close original stack
        selectWindow(origTitle);
        close();
        
        // Select and save the MIP
        selectWindow(maxTitle);
        savePath = dir + baseName + "_MIP.tif";
        saveAs("Tiff", savePath);
        print("  Saved MIP: " + baseName + "_MIP.tif");
        close();
    } else {
        // Single slice - just save as is
        print("  Single slice - saving without projection");
        savePath = dir + baseName + "_MIP.tif";
        saveAs("Tiff", savePath);
        print("  Saved: " + baseName + "_MIP.tif");
        close();
    }
}

print("=== COMPLETE ===");
print("Processed " + numImages + " images.");

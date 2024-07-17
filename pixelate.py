from PIL import Image

def pixelate(input_image_path, output_image_path, pixel_size):
    image = Image.open(input_image_path)
    
    width, height = image.size
    new_width = width // pixel_size
    new_height = height // pixel_size
    
    image_pixelated = image.resize((new_width, new_height), resample=Image.NEAREST)
    
    result = image_pixelated.resize((width, height), Image.NEAREST)
    
    result.save(output_image_path)
    
pixelate("C:/Users/Israel/Pictures/me/WhatsApp Image 2024-03-26 at 12.48.48.jpeg", './out.jpeg', 32)

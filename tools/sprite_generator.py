#!/usr/bin/env python3
"""
Procedural Pixel Art Sprite Generator for Embers of the Earth
Generates crop sprites, soil tiles, and character sprites with mutations
"""

from PIL import Image, ImageDraw, ImageFilter
import json
import os
import random
from pathlib import Path
from typing import Dict, List, Tuple, Optional

# Color palettes (muted copper, orange, ash tones)
PALETTE = {
    "copper": {
        "light": (218, 165, 132),
        "medium": (184, 115, 51),
        "dark": (139, 69, 19),
    },
    "rust": {
        "light": (183, 132, 97),
        "medium": (139, 87, 66),
        "dark": (101, 67, 33),
    },
    "ash": {
        "light": (169, 169, 169),
        "medium": (128, 128, 128),
        "dark": (64, 64, 64),
    },
    "steam": {
        "light": (245, 245, 245),
        "medium": (211, 211, 211),
        "dark": (169, 169, 169),
    },
}

class SpriteGenerator:
    """Main sprite generator class"""
    
    def __init__(self, output_dir: str = "assets/generated"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        random.seed()
    
    def generate_crop_sprite(self, crop_name: str, growth_stage: int, 
                            max_stages: int = 5, biomechanical: bool = True,
                            mutations: List[str] = None) -> Image.Image:
        """Generate a crop sprite with optional mutations"""
        size = 32
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # Base shape based on crop type
        if "wheat" in crop_name.lower():
            sprite = self._draw_wheat(draw, size, growth_stage, max_stages)
        elif "root" in crop_name.lower():
            sprite = self._draw_root_vegetable(draw, size, growth_stage, max_stages)
        elif "bean" in crop_name.lower():
            sprite = self._draw_bean(draw, size, growth_stage, max_stages)
        elif "moss" in crop_name.lower():
            sprite = self._draw_moss(draw, size, growth_stage, max_stages)
        else:
            sprite = self._draw_generic_crop(draw, size, growth_stage, max_stages)
        
        # Apply biomechanical mutations
        if biomechanical:
            sprite = self._apply_biomechanical_overlay(sprite, mutations or [])
        
        return sprite
    
    def _draw_wheat(self, draw: ImageDraw, size: int, 
                    growth_stage: int, max_stages: int) -> Image.Image:
        """Draw wheat-like crop"""
        center_x, center_y = size // 2, size // 2
        stage_progress = growth_stage / max_stages
        
        # Stalk
        stalk_height = int(size * 0.7 * stage_progress)
        stalk_color = PALETTE["copper"]["medium"]
        draw.rectangle([center_x - 1, center_y, center_x + 1, center_y + stalk_height], 
                      fill=stalk_color)
        
        # Head (grain)
        if stage_progress > 0.3:
            head_size = int(6 * stage_progress)
            draw.ellipse([center_x - head_size, center_y - head_size * 2,
                         center_x + head_size, center_y - head_size], 
                        fill=PALETTE["copper"]["light"])
        
        return draw._image
    
    def _draw_root_vegetable(self, draw: ImageDraw, size: int,
                            growth_stage: int, max_stages: int) -> Image.Image:
        """Draw root vegetable crop"""
        center_x, center_y = size // 2, size // 2
        stage_progress = growth_stage / max_stages
        
        # Root (below ground)
        root_size = int(8 * stage_progress)
        draw.ellipse([center_x - root_size, center_y, 
                     center_x + root_size, center_y + root_size * 2],
                    fill=PALETTE["rust"]["medium"])
        
        # Leaves (above ground)
        if stage_progress > 0.4:
            leaf_height = int(10 * stage_progress)
            draw.rectangle([center_x - 2, center_y - leaf_height,
                           center_x + 2, center_y],
                          fill=PALETTE["copper"]["dark"])
        
        return draw._image
    
    def _draw_bean(self, draw: ImageDraw, size: int,
                  growth_stage: int, max_stages: int) -> Image.Image:
        """Draw bean crop (spiral pattern)"""
        center_x, center_y = size // 2, size // 2
        stage_progress = growth_stage / max_stages
        
        # Spiral vine
        if stage_progress > 0.3:
            points = []
            for i in range(int(8 * stage_progress)):
                angle = i * 0.5
                radius = i * 1.5
                x = center_x + int(radius * (angle % 6.28) * 0.5)
                y = center_y + int(radius * (angle % 6.28) * 0.5)
                points.append((x, y))
            
            for i in range(len(points) - 1):
                draw.line([points[i], points[i + 1]], 
                         fill=PALETTE["copper"]["medium"], width=2)
        
        # Beans
        if stage_progress > 0.6:
            bean_size = 4
            for i in range(int(3 * stage_progress)):
                offset = i * 8
                draw.ellipse([center_x - bean_size + offset % 6,
                             center_y - bean_size + offset % 4,
                             center_x + bean_size + offset % 6,
                             center_y + bean_size + offset % 4],
                            fill=PALETTE["rust"]["light"])
        
        return draw._image
    
    def _draw_moss(self, draw: ImageDraw, size: int,
                  growth_stage: int, max_stages: int) -> Image.Image:
        """Draw moss crop (irregular patches)"""
        center_x, center_y = size // 2, size // 2
        stage_progress = growth_stage / max_stages
        
        # Moss patches
        patch_count = int(5 * stage_progress)
        for _ in range(patch_count):
            x = random.randint(center_x - 10, center_x + 10)
            y = random.randint(center_y - 10, center_y + 10)
            patch_size = random.randint(3, 8)
            draw.ellipse([x - patch_size, y - patch_size,
                         x + patch_size, y + patch_size],
                        fill=PALETTE["ash"]["medium"])
        
        return draw._image
    
    def _draw_generic_crop(self, draw: ImageDraw, size: int,
                          growth_stage: int, max_stages: int) -> Image.Image:
        """Draw generic crop shape"""
        center_x, center_y = size // 2, size // 2
        stage_progress = growth_stage / max_stages
        
        # Simple stalk
        stalk_height = int(size * 0.6 * stage_progress)
        draw.rectangle([center_x - 2, center_y,
                       center_x + 2, center_y + stalk_height],
                      fill=PALETTE["copper"]["medium"])
        
        return draw._image
    
    def _apply_biomechanical_overlay(self, img: Image.Image,
                                     mutations: List[str]) -> Image.Image:
        """Apply biomechanical mutations (rust, gears, pipes)"""
        overlay = img.copy()
        draw = ImageDraw.Draw(overlay)
        
        for mutation in mutations:
            if mutation == "rust_veins":
                self._draw_rust_veins(draw, img.size)
            elif mutation == "gear_leaves":
                self._draw_gear_leaves(draw, img.size)
            elif mutation == "steam_pipes":
                self._draw_steam_pipes(draw, img.size)
            elif mutation == "metal_joints":
                self._draw_metal_joints(draw, img.size)
        
        # Blend overlay with original
        result = Image.alpha_composite(img, overlay)
        return result
    
    def _draw_rust_veins(self, draw: ImageDraw, size: Tuple[int, int]):
        """Draw rust veins on sprite"""
        width, height = size
        for _ in range(random.randint(3, 6)):
            start_x = random.randint(0, width)
            start_y = random.randint(0, height)
            end_x = random.randint(0, width)
            end_y = random.randint(0, height)
            draw.line([(start_x, start_y), (end_x, end_y)],
                     fill=PALETTE["rust"]["dark"], width=1)
    
    def _draw_gear_leaves(self, draw: ImageDraw, size: Tuple[int, int]):
        """Draw gear-like leaves"""
        width, height = size
        for _ in range(random.randint(1, 3)):
            x = random.randint(5, width - 5)
            y = random.randint(5, height - 5)
            # Simple gear shape (circle with teeth)
            radius = random.randint(3, 5)
            draw.ellipse([x - radius, y - radius, x + radius, y + radius],
                        fill=PALETTE["copper"]["dark"])
            # Teeth
            for angle in range(0, 360, 45):
                rad = angle * 3.14159 / 180
                tooth_x = x + int((radius + 2) * (rad))
                tooth_y = y + int((radius + 2) * (rad))
                draw.rectangle([tooth_x - 1, tooth_y - 1, tooth_x + 1, tooth_y + 1],
                              fill=PALETTE["copper"]["dark"])
    
    def _draw_steam_pipes(self, draw: ImageDraw, size: Tuple[int, int]):
        """Draw steam pipes"""
        width, height = size
        for _ in range(random.randint(1, 2)):
            x = random.randint(0, width)
            y = random.randint(0, height)
            length = random.randint(5, 15)
            draw.rectangle([x, y, x + length, y + 2],
                          fill=PALETTE["steam"]["medium"])
    
    def _draw_metal_joints(self, draw: ImageDraw, size: Tuple[int, int]):
        """Draw metal joints"""
        width, height = size
        for _ in range(random.randint(2, 4)):
            x = random.randint(2, width - 2)
            y = random.randint(2, height - 2)
            draw.rectangle([x - 2, y - 2, x + 2, y + 2],
                          fill=PALETTE["copper"]["dark"])
    
    def generate_soil_tile(self, soil_type: str, memory: Dict = None) -> Image.Image:
        """Generate a soil tile based on type and memory"""
        size = 32
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # Base soil color
        soil_colors = {
            "ferro_soil": PALETTE["copper"]["medium"],
            "fungal_soil": PALETTE["ash"]["medium"],
            "ash_soil": PALETTE["ash"]["dark"],
            "pure_bio_soil": (101, 120, 81),  # Slightly green
            "scrap_heap": PALETTE["rust"]["dark"],
        }
        
        base_color = soil_colors.get(soil_type, PALETTE["ash"]["medium"])
        
        # Draw base with noise
        for x in range(size):
            for y in range(size):
                noise = random.randint(-10, 10)
                color = tuple(max(0, min(255, c + noise)) for c in base_color)
                if random.random() < 0.3:  # Add texture
                    draw.point((x, y), fill=color)
        
        # Add cracks based on memory
        if memory and memory.get("years_used", 0) > 3:
            years = memory["years_used"]
            crack_count = min(3, years // 2)
            for _ in range(crack_count):
                self._draw_crack(draw, size)
        
        # Add pipes/mechanical elements for ferro_soil
        if soil_type == "ferro_soil":
            self._draw_metal_pipes(draw, size)
        
        return img
    
    def _draw_crack(self, draw: ImageDraw, size: int):
        """Draw a crack in the soil"""
        start_x = random.randint(0, size)
        start_y = random.randint(0, size)
        end_x = random.randint(0, size)
        end_y = random.randint(0, size)
        draw.line([(start_x, start_y), (end_x, end_y)],
                 fill=PALETTE["ash"]["dark"], width=1)
    
    def _draw_metal_pipes(self, draw: ImageDraw, size: int):
        """Draw metal pipes in ferro soil"""
        for _ in range(random.randint(1, 2)):
            x = random.randint(5, size - 5)
            y = random.randint(5, size - 5)
            length = random.randint(5, 10)
            if random.random() < 0.5:
                draw.rectangle([x, y, x + length, y + 1],
                              fill=PALETTE["copper"]["dark"])
            else:
                draw.rectangle([x, y, x + 1, y + length],
                              fill=PALETTE["copper"]["dark"])
    
    def generate_character_sprite(self, traits: List[str],
                                 age: int, generation: int) -> Image.Image:
        """Generate a character sprite based on traits"""
        size = 32
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # Base body
        body_color = PALETTE["copper"]["light"]
        draw.ellipse([size // 2 - 8, size // 2 - 4,
                     size // 2 + 8, size // 2 + 12],
                    fill=body_color)
        
        # Apply trait-based mutations
        for trait in traits:
            if "mechanical" in trait.lower():
                self._add_mechanical_eye(draw, size)
            elif "limb" in trait.lower() or "prosthetic" in trait.lower():
                self._add_prosthetic_limb(draw, size)
            elif "soot" in trait.lower() or "stained" in trait.lower():
                self._add_soot_stains(draw, size)
        
        # Age effects
        if age > 50:
            self._add_wrinkles(draw, size)
        
        return img
    
    def _add_mechanical_eye(self, draw: ImageDraw, size: int):
        """Add mechanical eye to character"""
        eye_x, eye_y = size // 2 - 3, size // 2 - 2
        # Eye socket
        draw.ellipse([eye_x - 3, eye_y - 3, eye_x + 3, eye_y + 3],
                    fill=(50, 50, 50))
        # Gear eye
        draw.ellipse([eye_x - 2, eye_y - 2, eye_x + 2, eye_y + 2],
                    fill=PALETTE["copper"]["dark"])
    
    def _add_prosthetic_limb(self, draw: ImageDraw, size: int):
        """Add prosthetic limb"""
        # Simple metal arm
        draw.rectangle([size // 2 + 6, size // 2,
                       size // 2 + 10, size // 2 + 8],
                      fill=PALETTE["copper"]["dark"])
    
    def _add_soot_stains(self, draw: ImageDraw, size: int):
        """Add soot stains to clothing"""
        for _ in range(random.randint(2, 5)):
            x = random.randint(size // 2 - 6, size // 2 + 6)
            y = random.randint(size // 2, size // 2 + 10)
            draw.point((x, y), fill=(40, 40, 40))
    
    def _add_wrinkles(self, draw: ImageDraw, size: int):
        """Add age wrinkles"""
        for _ in range(3):
            x = random.randint(size // 2 - 4, size // 2 + 4)
            y = size // 2 - 1
            draw.line([(x - 2, y), (x + 2, y)],
                     fill=(80, 60, 40), width=1)
    
    def batch_generate_crops(self, crop_data: List[Dict]):
        """Generate all crop sprites from crop data"""
        crops_dir = self.output_dir / "crops"
        crops_dir.mkdir(exist_ok=True)
        
        for crop in crop_data:
            crop_name = crop["name"]
            max_stages = crop.get("growth_stages", 5)
            biomechanical = crop.get("biomechanical", True)
            
            # Generate for each growth stage
            for stage in range(1, max_stages + 1):
                mutations = []
                if biomechanical:
                    # Random biomechanical mutations
                    mutation_options = ["rust_veins", "gear_leaves", "steam_pipes"]
                    mutations = random.sample(mutation_options, 
                                            random.randint(0, 2))
                
                sprite = self.generate_crop_sprite(
                    crop_name, stage, max_stages, biomechanical, mutations
                )
                
                filename = f"{crop_name.lower()}_stage_{stage}.png"
                sprite.save(crops_dir / filename)
                print(f"Generated: {filename}")
    
    def batch_generate_soil_tiles(self, soil_types: List[str]):
        """Generate soil tile sprites"""
        tiles_dir = self.output_dir / "tiles"
        tiles_dir.mkdir(exist_ok=True)
        
        for soil_type in soil_types:
            # Generate base tile
            tile = self.generate_soil_tile(soil_type)
            filename = f"{soil_type}.png"
            tile.save(tiles_dir / filename)
            print(f"Generated: {filename}")
            
            # Generate with memory variations
            for years in [3, 5, 10]:
                memory = {"years_used": years, "mood": "tired"}
                tile = self.generate_soil_tile(soil_type, memory)
                filename = f"{soil_type}_memory_{years}.png"
                tile.save(tiles_dir / filename)
                print(f"Generated: {filename}")


def main():
    """Main function to generate all sprites"""
    generator = SpriteGenerator("assets/generated")
    
    # Load crop data
    crop_data_path = Path("data/crops.json")
    if crop_data_path.exists():
        with open(crop_data_path) as f:
            crops = json.load(f)
        generator.batch_generate_crops(crops)
    
    # Generate soil tiles
    soil_types = ["ferro_soil", "fungal_soil", "ash_soil", 
                  "pure_bio_soil", "scrap_heap"]
    generator.batch_generate_soil_tiles(soil_types)
    
    # Generate example character
    character = generator.generate_character_sprite(
        ["mechanically_gifted"], 45, 1
    )
    generator.output_dir.mkdir(exist_ok=True)
    character.save(generator.output_dir / "character_example.png")
    print("Generated: character_example.png")


if __name__ == "__main__":
    main()


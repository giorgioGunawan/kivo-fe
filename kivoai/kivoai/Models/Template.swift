//
//  Template.swift
//  kivoai
//

import Foundation

struct Template: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let category: TemplateCategory
    let creditCost: Int
    let requiresPhoto: Bool
    let showsAdvancedPrompt: Bool
    let basePrompt: String
    let photographHint: String
    let exampleDescription: String
    
    static let sampleTemplates: [Template] = [
        // MARK: - PRANKS & CHAOS
        Template(
            id: "prank_home_intruder",
            title: "Home Intruder",
            subtitle: "Terrifying shadow in the background",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "Highly realistic, grainy CCTV security camera footage from inside a dark living room at 3:00 AM. A mysterious, frightening shadow figure with glowing eyes and a dark hooded cloak is standing perfectly still in the distant hallway behind the subject. The figure is slightly translucent and blurry, adding to the supernatural horror. Dim cold lighting, digital red timestamp in corner, high contrast, cinematic suspense, ultra-realistic textures.",
            photographHint: "Take a photo in your hallway or living room",
            exampleDescription: "A creepy figure standing at the end of your dark hallway"
        ),
        Template(
            id: "prank_clown_3am",
            title: "Midnight Clown",
            subtitle: "He's staring through the window...",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "Terrifying flash-photography shot of a dark window at night. Pressed against the glass from the outside is a realistic, sinister clown with smudged face paint and a haunting grin. The clown's eyes are wide and bloodshot. Raindrops on the window pane are sharply focused. The subject is partially visible in the reflection, oblivious. Gritty, low-light horror aesthetic, 8k resolution.",
            photographHint: "Take a photo of your window at night",
            exampleDescription: "A scary clown staring at you from outside"
        ),
        Template(
            id: "prank_under_bed",
            title: "Under The Bed",
            subtitle: "Something is hiding there...",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "Flash-photography style shot from a low angle looking under a bed in a dark bedroom. Peeking out from the shadows is a realistic, terrifying face with wide, unblinking eyes and a sinister grin. The floor is dusty with realistic textures. The subject in the photo is partially visible, appearing to be asleep on the bed. Horror aesthetic, intense shadows, sharp details on the creeping entity, 8k resolution.",
            photographHint: "Take a photo of your bed from a low angle",
            exampleDescription: "A terrifying face peeking from under your bed"
        ),
        Template(
            id: "prank_broken_tv",
            title: "Smashed TV",
            subtitle: "The ultimate heart-attack prank",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "Hyper-realistic close-up of a high-end OLED television screen that has been completely shattered. Massive spider-web cracks radiate from a central impact point as if hit by a heavy object. Dead pixels, colorful glitchy vertical lines, and inner liquid crystal leaking out. The reflection on the screen shows a realistic living room environment. 8k resolution, macro photography, sharp focus on the glass shards.",
            photographHint: "Take a photo of your TV from the front",
            exampleDescription: "Your TV looks like it was hit by a baseball"
        ),
        Template(
            id: "prank_spilled_wine",
            title: "Wine Disaster",
            subtitle: "Spilled on the white couch!",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "Hyper-realistic close-up photo of a massive, dark red wine stain spreading quickly across a premium white fabric sofa. An empty wine glass is lying on its side. The fabric texture is extremely detailed, showing the liquid soaking into the fibers. Soft natural light, shallow depth of field, sharp focus on the xwet stain, 8k resolution.",
            photographHint: "Take a photo of your couch",
            exampleDescription: "A massive, realistic red wine spill stain"
        ),
        Template(
            id: "prank_car_dent",
            title: "Totaled Car",
            subtitle: "Someone hit your car!",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "Highly detailed photograph of a luxury car with a massive, deep dent on the driver side door and a completely shattered side window. Paint is chipped and scratched realistically, with metal showing through. Shards of safety glass are scattered on the ground. Realistic outdoor lighting, overcast sky, reflective car surface, 8k resolution, cinematic quality.",
            photographHint: "Take a photo of your car from the side",
            exampleDescription: "A massive dent and broken window on your car"
        ),

        // MARK: - APPEARANCE & STYLE
        Template(
            id: "style_buzzcut",
            title: "Buzz Cut",
            subtitle: "See yourself with a fresh fade",
            category: .appearance,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "Photorealistic portrait of the subject with a perfectly executed, ultra-clean buzz cut and a high skin fade. The hair texture is extremely detailed, showing individual follicles and a sharp, symmetrical hairline. Natural studio lighting, soft shadows, sharp focus on the face and hair, professional photography style, 8k resolution.",
            photographHint: "Take a clear headshot against a plain wall",
            exampleDescription: "A clean, stylish buzz cut transformation"
        ),
        Template(
            id: "style_korean_fashion",
            title: "Seoul Streetwear",
            subtitle: "Modern Korean 'Oversized' style",
            category: .appearance,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "A professional street-style photograph of the subject in Seoul, wearing a premium Korean fashion outfit. Extremely oversized trench coat, wide-leg trousers, minimalist leather sneakers, and a structured tote bag. Neutral tones (beige, charcoal, cream). Background is a modern architectural street in Gangnam. High-end fashion editorial look, soft natural light, selective focus, 8k resolution.",
            photographHint: "Full body photo in natural light",
            exampleDescription: "Chic and modern Korean streetwear look"
        ),
        Template(
            id: "style_sleeve_tattoo",
            title: "Complete Sleeve",
            subtitle: "Try on a highly-detailed tattoo",
            category: .appearance,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "Hyper-realistic close-up of a human arm covered in an intricate, black-and-grey neo-traditional sleeve tattoo. The design includes detailed lions, roses, and geometric patterns. The ink looks perfectly embedded in the skin with realistic texture, slight redness around new lines, and subtle skin pores visible. Soft natural lighting, sharp focus, 8k resolution.",
            photographHint: "Take a photo of your bare arm",
            exampleDescription: "Intricate black and grey sleeve tattoo"
        ),

        // MARK: - FANTASY & ROLEPLAY
        Template(
            id: "fan_celebrity_date",
            title: "Celebrity Date",
            subtitle: "Dinner with your favorite star",
            category: .fantasy,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "Highly realistic, paparazzi-style photograph of the subject sitting at a candle-lit table in a luxury rooftop restaurant in Paris. Sitting directly across and laughing is a world-famous celebrity. Warm ambient lighting, bokeh background of the Eiffel Tower, expensive wine glasses, high-end fashion, cinematic atmosphere, 8k resolution, authentic film look.",
            photographHint: "Photo of yourself sitting at a table",
            exampleDescription: "A romantic dinner with a Hollywood star"
        ),
        Template(
            id: "fan_wedding",
            title: "Royal Wedding",
            subtitle: "Your special day in a castle",
            category: .fantasy,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "A breathtaking, professional wedding photograph of the subject dressed in a magnificent, lace-detailed designer wedding gown or a sharp white tuxedo. The setting is a grand, sun-drenched cathedral with stained glass windows. Golden hour light streaming in, flower petals on the floor, soft romantic focus, ultra-detailed fabric, 8k resolution, vogue magazine style.",
            photographHint: "Full body formal photo",
            exampleDescription: "You at your dream wedding in a cathedral"
        ),

        // MARK: - POP CULTURE & GAMES
        Template(
            id: "pop_gta_version",
            title: "GTA Loading Screen",
            subtitle: "Welcome to Los Santos",
            category: .popCulture,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "Iconic Grand Theft Auto V loading screen art style. Digital illustration of the subject with thick black outlines, bold cell shading, and vibrant saturated colors. The subject looks like a stylized video game character holding a stack of cash or leanin against a luxury car. Background features a palm-tree-lined Los Angeles street with a sunset glow. High-quality vector art style.",
            photographHint: "Cool pose, looking at camera",
            exampleDescription: "You as a GTA 5 loading screen character"
        ),
        Template(
            id: "pop_minecraft",
            title: "Minecraft Avatar",
            subtitle: "Enter the world of blocks",
            category: .popCulture,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "A custom Minecraft character skin that accurately replicates the subject's features, hair, and clothing in a 64x64 pixel blocky style. The 3D avatar is standing in a lush Minecraft birch forest holding a diamond sword. Subsurface scattering on skin blocks, sharp shadows, iconic blocky aesthetic, 4k render.",
            photographHint: "Photo showing your face and outfit clearly",
            exampleDescription: "A custom 3D Minecraft skin version of you"
        ),
        Template(
            id: "pop_fortnite",
            title: "Fortnite Skin",
            subtitle: "Drop into the battlefield",
            category: .popCulture,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "A high-quality 3D render of the subject as a playable Fortnite character. Clean, smooth 3D modeling, vibrant colors, wearing futuristic tactical armor with glowing neon accents. The character is performing a 'Victory Royale' emote in the middle of a colorful Fortnite-themed landscape. Unreal Engine 5 render style, sharp details, iconic game aesthetic.",
            photographHint: "Full body standing photo",
            exampleDescription: "You as a custom Level 100 Fortnite skin"
        ),

        // MARK: - STYLIZATION
        Template(
            id: "style_pixar",
            title: "Disney/Pixar",
            subtitle: "Turn into a 3D animated hero",
            category: .stylization,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "A charming 3D character design in the style of a modern Disney/Pixar movie. The subject has large expressive eyes, smooth skin textures, and stylized, bouncy hair. The lighting is warm and magical, with high-quality global illumination. The character is wearing a cute, detailed outfit. Background is a whimsical, colorful landscape. 8k resolution, Octane render.",
            photographHint: "Clear face photo with a big smile",
            exampleDescription: "A high-quality 3D Pixar version of you"
        ),
        Template(
            id: "style_anime",
            title: "Anime Protagonist",
            subtitle: "Studio Ghibli aesthetic",
            category: .stylization,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "A beautiful, hand-drawn anime illustration in the iconic Studio Ghibli style. The subject features soft features, expressive eyes, and natural-looking hair. The background is a sprawling green meadow with a blue sky and fluffy white clouds. Painted watercolor textures, nostalgic atmosphere, high-quality traditional cel-shading art.",
            photographHint: "Clear headshot or waist-up photo",
            exampleDescription: "You as a hero in a Studio Ghibli film"
        ),
        Template(
            id: "style_claymation",
            title: "Claymation Style",
            subtitle: "Wallace & Gromit aesthetic",
            category: .stylization,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "Hand-crafted claymation character model of the subject in the style of Aardman Animations. Visible thumbprints in the clay, slightly uneven textures, and chunky, expressive features. The character is wearing a tiny knitted sweater. Background is a cozy, miniature handmade room with clay furniture. Soft, warm studio lighting, characteristic stop-motion feel, 8k resolution.",
            photographHint: "Frontal photo with a warm expression",
            exampleDescription: "A charming handmade clay version of you"
        ),
        Template(
            id: "style_lego",
            title: "LEGO Minifigure",
            subtitle: "Everything is awesome!",
            category: .stylization,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "A professional studio photograph of a custom LEGO minifigure that looks exactly like the subject. Authentic plastic texture with realistic mold lines and slight sheen. The minifigure features custom-printed clothes and hair that match the subject's style. Sitting on a LEGO baseplate with a blurry LEGO city in the background. Miniature photography, sharp focus, vibrant colors.",
            photographHint: "Photo showing your favorite outfit",
            exampleDescription: "A custom LEGO minifigure version of you"
        ),

        // MARK: - TRANSFORMATION
        Template(
            id: "trans_zombie",
            title: "The Last of Us",
            subtitle: "Zombie apocalypse Survivor",
            category: .transformation,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "A cinematic, hyper-realistic portrait of the subject transformed into a Clicker from The Last of Us. Cordyceps fungus is erupting from the head in intricate, terrifying orange and white patterns. Clothes are tattered and weathered. The lighting is dark and moody, with dust motes floating in a single beam of light. Intense horror atmosphere, ultra-detailed textures, 8k resolution.",
            photographHint: "Close-up face photo, neutral expression",
            exampleDescription: "A terrifyingly realistic zombie transformation"
        ),
        Template(
            id: "trans_bodybuilder",
            title: "Superhero Physique",
            subtitle: "Instant gym transformation",
            category: .transformation,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "A professional fitness photography shot of the subject with an elite, superhero-level physique. Extremely defined muscles, vascularity, and 6-pack abs. The subject is standing in a gritty, high-contrast gym with dramatic rim lighting. Sweat glistenin on skin, ultra-detailed muscle fibers, cinematic quality, 8k resolution, Men's Health magazine style.",
            photographHint: "Full body photo, preferably in gym wear",
            exampleDescription: "Your head on a world-class athlete's body"
        ),
        Template(
            id: "trans_age_progression",
            title: "10 Years Older",
            subtitle: "A glimpse into the future",
            category: .transformation,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "A photorealistic age-progression portrait. The subject's face features realistic signs of aging, including subtle forehead wrinkles, fine lines around the eyes, slightly thinner skin, and a few distinguished grey hairs in the eyebrows and temples. The essence and bone structure remain identical to the subject. Professional studio lighting, sharp focus, 8k resolution.",
            photographHint: "Clear front-facing headshot",
            exampleDescription: "A realistic look at yourself 10 years from now"
        ),

        // MARK: - SURVEILLANCE
        Template(
            id: "srv_grocery_store",
            title: "Grocery Cam",
            subtitle: "Busted in 4K",
            category: .surveillance,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "Highly realistic, top-down security camera footage from a bright grocery store aisle. The subject is caught in a candid, suspicious moment. Over-exposed florescent lighting, high digital noise, grainy texture. Digital overlay with 'AISLE 4 - CAM 12' and a red blinking 'REC' icon. Realistic convenience store environment, 8k resolution.",
            photographHint: "Take a photo in an aisle or corridor",
            exampleDescription: "Grainy convenience store security footage of you"
        ),
        Template(
            id: "srv_caught_stealing",
            title: "Airport Security",
            subtitle: "Caught on the hidden cam",
            category: .surveillance,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "Grainy, wide-angle monochromatic security camera footage from an airport terminal. The subject is seen at the center of the frame, caught in a suspicious pose. Low resolution, digital noise, high contrast black and white, digital timestamp 'SEC-CAM 04' in the corner. Fish-eye lens distortion, authentic surveillance look, high virality style.",
            photographHint: "Take a photo in an open crowded area",
            exampleDescription: "You caught on a grainy airport security camera"
        ),

        // MARK: - STATUS
        Template(
            id: "stat_forbes",
            title: "Forbes 30 Under 30",
            subtitle: "The world's next top CEO",
            category: .status,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "An authentic Forbes Magazine cover featuring a powerful, professional portrait of the subject. The subject is wearing a sharp, tailored luxury suit and standing in a modern glass office overlooking a city skyline. Bold 'FORBES' masthead at the top, headline 'THE FUTURE OF MODERN BUSINESS'. Crisp typography, high-end editorial lighting, 8k resolution, professional photography.",
            photographHint: "Formal photo in professional attire",
            exampleDescription: "You on the cover of Forbes magazine"
        ),
        Template(
            id: "stat_vogue",
            title: "Vogue Cover",
            subtitle: "The new face of fashion",
            category: .status,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            basePrompt: "A high-fashion, high-contrast Vogue Magazine cover featuring the subject. The subject is in a dramatic pose, wearing avant-garde luxury fashion and bold makeup. Minimalist background, professional studio lighting with deep shadows. Iconic 'VOGUE' masthead at the top. Sharp focus, ultra-detailed skin and fabric, 8k resolution.",
            photographHint: "High-fashion post, good lighting",
            exampleDescription: "You as a world-class model on Vogue's cover"
        ),
        Template(
            id: "stat_mugshot",
            title: "Mugshot",
            subtitle: "Breaking the internet",
            category: .status,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            basePrompt: "A highly realistic, gritty police mugshot of the subject. Standing against a grey height-chart background with black lines and numbers. Harsh, direct flash lighting, cast shadows on the wall, neutral expression. Subject is holding a black booking board with white text 'COUNTY JAIL - 047291'. Authentic high-contrast crime photography style.",
            photographHint: "Stand against a plain light-colored wall",
            exampleDescription: "A realistic and viral police mugshot"
        )
    ]
    
    static func templates(for category: TemplateCategory) -> [Template] {
        sampleTemplates.filter { $0.category == category }
    }
}

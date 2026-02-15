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
    let basePrompt: String
    let photographHint: String
    let exampleDescription: String

    static let sampleTemplates: [Template] = [

        // MARK: - PRANKS (6)

        Template(
            id: "prank_home_intruder",
            title: "Home Intruder",
            subtitle: "There's someone behind you...",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a shadowy intruder figure lurking in the background.",
            photographHint: "Face the camera with some open space visible behind you.",
            exampleDescription: "A shadowy figure lurking behind you in your own home"
        ),

        Template(
            id: "prank_smashed_tv",
            title: "Smashed TV",
            subtitle: "The ultimate heart-attack prank",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Shatter the TV screen with a realistic spider-web crack.",
            photographHint: "Straight-on photo of your full TV. Turn it off for best results.",
            exampleDescription: "Your TV screen shattered into a million pieces"
        ),

        Template(
            id: "prank_smashed_windshield",
            title: "Smashed Windshield",
            subtitle: "Someone hit your car!",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Shatter the windshield with realistic spider-web cracks from a central impact point.",
            photographHint: "Shoot forward through the windshield from the driver or passenger seat.",
            exampleDescription: "Your windshield smashed with a massive crack web"
        ),

        Template(
            id: "prank_totaled_car",
            title: "Totaled Car",
            subtitle: "Uh oh... who did this?",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add severe crash damage — crumpled body panels, shattered windows, and debris.",
            photographHint: "Stand in front of or beside your car with it filling most of the frame.",
            exampleDescription: "Your car looking completely totaled after a crash"
        ),

        Template(
            id: "prank_mugshot",
            title: "Mugshot",
            subtitle: "Breaking the internet",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a realistic police mugshot with a height-chart background and booking placard.",
            photographHint: "Straight-on headshot against a plain wall, neutral expression, even lighting.",
            exampleDescription: "A dead-serious, totally believable police mugshot"
        ),

        Template(
            id: "prank_grocery_cam",
            title: "Grocery Store Security Cam",
            subtitle: "Caught on camera",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Convert into grainy overhead CCTV footage with a 'CAM 04' overlay.",
            photographHint: "Any store aisle or corridor. A slightly elevated angle looks most like surveillance.",
            exampleDescription: "You caught doing something suspicious on a store security cam"
        ),

        // MARK: - HAIR (12)

        Template(
            id: "hair_buzz_cut",
            title: "Buzz Cut",
            subtitle: "Fresh fade, new you",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject a sharp buzz cut with a clean high skin fade.",
            photographHint: "Clear headshot, hair tied back, even lighting.",
            exampleDescription: "A sharp, clean buzz cut transformation"
        ),

        Template(
            id: "hair_korean_perm",
            title: "Korean Perm",
            subtitle: "Bouncy, effortless waves",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject a trendy Korean perm with bouncy, voluminous waves.",
            photographHint: "Clear headshot, hair down, good lighting.",
            exampleDescription: "Voluminous, bouncy Korean perm waves"
        ),

        Template(
            id: "hair_modern_mullet",
            title: "Modern Mullet",
            subtitle: "Business up front, party in the back",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject a modern mullet — short on top, longer in the back, faded sides.",
            photographHint: "Headshot or ¾ angle so the front and side of the head are visible.",
            exampleDescription: "A modern, fashion-forward mullet"
        ),

        Template(
            id: "hair_long_flow",
            title: "Long Flow",
            subtitle: "Shoulder-length and effortless",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject flowing, healthy shoulder-length hair.",
            photographHint: "Chest-up photo facing forward, neck and shoulders visible.",
            exampleDescription: "Beautiful, flowing shoulder-length hair"
        ),

        Template(
            id: "hair_pixie_cut",
            title: "Pixie Cut",
            subtitle: "Short, sharp, iconic",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject a sharp, textured pixie cut.",
            photographHint: "Well-lit headshot, hair pulled back tightly, plain background.",
            exampleDescription: "A sharp, chic pixie cut"
        ),

        Template(
            id: "hair_short_bob",
            title: "Short Bob",
            subtitle: "Classic, clean, timeless",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject a sleek chin-length bob with blunt ends.",
            photographHint: "Forward-facing headshot, jawline and neck visible in frame.",
            exampleDescription: "A sleek, classic chin-length bob"
        ),

        Template(
            id: "hair_curtain_bangs",
            title: "Curtain Bangs",
            subtitle: "Soft, face-framing, trendy",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add soft, wispy curtain bangs parted down the middle.",
            photographHint: "Headshot with forehead fully visible — no hat or headband.",
            exampleDescription: "Soft, face-framing curtain bangs"
        ),

        Template(
            id: "hair_wolf_cut",
            title: "Wolf Cut",
            subtitle: "Shaggy layers, full volume",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject a heavily layered, voluminous wolf cut with curtain bangs.",
            photographHint: "Headshot or chest-up, face and hair clearly visible.",
            exampleDescription: "A shaggy, voluminous wolf cut with curtain bangs"
        ),

        Template(
            id: "hair_long_sleek_straight",
            title: "Long Sleek Straight",
            subtitle: "Glossy, smooth, and razor-straight",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject long, pin-straight, ultra-glossy hair with a center part.",
            photographHint: "Chest-up or waist-up photo facing forward, shoulders visible.",
            exampleDescription: "Long, ultra-straight, mirror-glossy hair"
        ),

        Template(
            id: "hair_hollywood_blowout",
            title: "Hollywood Blowout",
            subtitle: "Glamorous, silky waves",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject a glamorous Hollywood blowout with voluminous silky waves.",
            photographHint: "Well-lit headshot or bust photo, shoulders in frame.",
            exampleDescription: "A glamorous, voluminous Hollywood blowout"
        ),

        Template(
            id: "hair_platinum_blonde",
            title: "Platinum Blonde",
            subtitle: "Ice cold, boldly bright",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Change the subject's hair to bright platinum blonde.",
            photographHint: "Clear headshot in bright, even lighting.",
            exampleDescription: "Striking platinum blonde hair, icy and bright"
        ),

        Template(
            id: "hair_pastel_pink",
            title: "Pastel Pink",
            subtitle: "Dreamy, soft, and sweet",
            category: .hair,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Change the subject's hair to soft pastel pink.",
            photographHint: "Clear headshot in bright, even lighting.",
            exampleDescription: "Soft, dreamy pastel pink hair"
        ),

        // MARK: - TATTOOS (8)

        Template(
            id: "tattoo_bw_sleeve",
            title: "Full Sleeve",
            subtitle: "Black & grey realism",
            category: .tattoos,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a detailed black and grey realism tattoo sleeve to the arm.",
            photographHint: "Bare arm in good lighting, from shoulder to wrist.",
            exampleDescription: "A full black and grey realism tattoo sleeve"
        ),

        Template(
            id: "tattoo_japanese_sleeve",
            title: "Japanese Irezumi Sleeve",
            subtitle: "Traditional bold and colorful",
            category: .tattoos,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a traditional Japanese Irezumi tattoo sleeve with koi fish, cherry blossoms, and waves.",
            photographHint: "Bare arm in good lighting, from shoulder to wrist.",
            exampleDescription: "A vibrant full Japanese Irezumi sleeve tattoo"
        ),

        Template(
            id: "tattoo_fine_line_floral",
            title: "Fine Line Floral",
            subtitle: "Delicate botanical forearm piece",
            category: .tattoos,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add delicate fine-line floral tattoos to the forearm.",
            photographHint: "Close-up of bare forearm, inner side facing up, even lighting.",
            exampleDescription: "Delicate fine-line botanical tattoos on the forearm"
        ),

        Template(
            id: "tattoo_minimal_quote",
            title: "Minimal Quote",
            subtitle: "Simple script on the forearm",
            category: .tattoos,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a simple elegant script tattoo to the forearm.",
            photographHint: "Close-up of bare forearm, inner side facing up.",
            exampleDescription: "An elegant script quote tattoo on the forearm"
        ),

        Template(
            id: "tattoo_snake_forearm",
            title: "Snake Wrap",
            subtitle: "Serpent coiled around the forearm",
            category: .tattoos,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a detailed snake tattoo coiling and wrapping around the forearm.",
            photographHint: "Bare forearm, slightly rotated to show both sides.",
            exampleDescription: "A detailed snake tattoo wrapping around the forearm"
        ),

        Template(
            id: "tattoo_tribal_polynesian",
            title: "Tribal Polynesian",
            subtitle: "Bold patterns on the upper arm",
            category: .tattoos,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add bold Polynesian tribal tattoo patterns to the upper arm and shoulder.",
            photographHint: "Bare upper arm and shoulder, arm held out at a 45° angle.",
            exampleDescription: "Bold Polynesian tribal tattoos covering the shoulder and bicep"
        ),

        Template(
            id: "tattoo_patchwork",
            title: "Patchwork Tattoos",
            subtitle: "Eclectic flash art collection",
            category: .tattoos,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a collection of patchwork flash tattoos scattered naturally across the arm.",
            photographHint: "Bare arm from shoulder to wrist in good lighting.",
            exampleDescription: "An eclectic collection of patchwork tattoos across the arm"
        ),

        Template(
            id: "tattoo_full_back_dragon",
            title: "Full Back Dragon",
            subtitle: "Massive dragon tattoo, full back",
            category: .tattoos,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a massive detailed dragon tattoo covering the full back.",
            photographHint: "Bare back fully in frame from shoulders to lower back.",
            exampleDescription: "A massive, dramatic dragon tattoo covering the full back"
        ),

        // MARK: - CARTOON (8)

        Template(
            id: "cartoon_bratz",
            title: "Bratz Doll",
            subtitle: "Y2K glam, oversized everything",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a Bratz doll illustration with oversized head, glossy lips, and Y2K fashion.",
            photographHint: "Clear headshot or chest-up, any expression.",
            exampleDescription: "You as a glamorous, fashion-forward Bratz doll"
        ),

        Template(
            id: "cartoon_lego",
            title: "LEGO Minifigure",
            subtitle: "Everything is awesome!",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a custom LEGO minifigure with a matching face and outfit.",
            photographHint: "Face and outfit clearly visible in the photo.",
            exampleDescription: "A custom LEGO minifigure version of you"
        ),

        Template(
            id: "cartoon_action_figure",
            title: "Toy Box / Action Figure",
            subtitle: "Boxed and ready for the shelf",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Place the subject as a boxed action figure in colorful toy packaging.",
            photographHint: "Full-body photo, standing straight, plain background.",
            exampleDescription: "You as a boxed action figure on a store shelf"
        ),

        Template(
            id: "cartoon_ghibli",
            title: "Studio Ghibli Style",
            subtitle: "Soft, painterly, and magical",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a hand-painted Studio Ghibli character illustration.",
            photographHint: "Clear headshot or waist-up, natural expression.",
            exampleDescription: "You as a character in a Studio Ghibli film"
        ),

        Template(
            id: "cartoon_anime",
            title: "Anime Protagonist",
            subtitle: "Main character energy",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a vibrant anime protagonist illustration.",
            photographHint: "Headshot or waist-up, facing the camera.",
            exampleDescription: "You as the main character in an anime series"
        ),

        Template(
            id: "cartoon_pixar",
            title: "Pixar Style",
            subtitle: "3D animated and full of heart",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a 3D Pixar-style animated character.",
            photographHint: "Clear headshot, expressive face, even lighting.",
            exampleDescription: "You as a lovable 3D Pixar character"
        ),

        Template(
            id: "cartoon_simpsons",
            title: "The Simpsons Style",
            subtitle: "Welcome to Springfield",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a Simpsons character with classic yellow skin and bold outlines.",
            photographHint: "Clear headshot or chest-up, any expression.",
            exampleDescription: "Your very own Springfield Simpsons character"
        ),

        Template(
            id: "cartoon_claymation",
            title: "Claymation Style",
            subtitle: "Wallace & Gromit vibes",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a handcrafted Aardman-style claymation character.",
            photographHint: "Clear frontal headshot, even soft lighting.",
            exampleDescription: "A charming handmade claymation version of you"
        ),

        // MARK: - FACE TRANSFORMATIONS (5)

        Template(
            id: "face_baby",
            title: "Baby Version",
            subtitle: "You, but tiny and adorable",
            category: .faceTransformations,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform the subject into an adorable baby version of themselves.",
            photographHint: "Clear straight-on headshot, even lighting, plain background.",
            exampleDescription: "An adorable baby version of your exact face"
        ),

        Template(
            id: "face_oldify",
            title: "Oldify",
            subtitle: "20 years into the future",
            category: .faceTransformations,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Age the subject by 20 years — wrinkles, greying temples, and deeper skin lines.",
            photographHint: "Forward-facing headshot, no strong shadows on the face.",
            exampleDescription: "A realistic look at yourself 20 years from now"
        ),

        Template(
            id: "face_youngify",
            title: "Youngify",
            subtitle: "Turn back the clock",
            category: .faceTransformations,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "De-age the subject by 10–15 years with smoother skin and a fresher complexion.",
            photographHint: "Clear headshot in even lighting, relaxed expression.",
            exampleDescription: "A realistic younger version of your face"
        ),

        Template(
            id: "face_weight_gain",
            title: "Weight Gain",
            subtitle: "A little more of you",
            category: .faceTransformations,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Make the subject look noticeably heavier with a fuller face and rounder cheeks.",
            photographHint: "Chest-up or waist-up, straight-on angle, even lighting.",
            exampleDescription: "A natural-looking weight gain transformation"
        ),

        Template(
            id: "face_weight_loss",
            title: "Weight Loss",
            subtitle: "Your lean, sculpted look",
            category: .faceTransformations,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Make the subject look noticeably slimmer with defined cheekbones and a sharper jawline.",
            photographHint: "Chest-up or waist-up, straight-on angle, even lighting.",
            exampleDescription: "A natural-looking weight loss transformation"
        ),

        // MARK: - PEOPLE (3)

        Template(
            id: "people_celebrity",
            title: "Celebrity",
            subtitle: "Pick one or get a surprise",
            category: .people,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a famous celebrity naturally beside the subject in the photo.",
            photographHint: "Clear headshot or waist-up. Type a celebrity name if you have someone in mind.",
            exampleDescription: "You in a photo with a famous celebrity"
        ),

        Template(
            id: "people_ai_boyfriend",
            title: "AI Boyfriend",
            subtitle: "Your perfect partner",
            category: .people,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add an attractive AI boyfriend naturally beside the subject.",
            photographHint: "Chest-up or full-body in good lighting, relaxed pose.",
            exampleDescription: "A real-looking couple photo with your AI boyfriend"
        ),

        Template(
            id: "people_ai_girlfriend",
            title: "AI Girlfriend",
            subtitle: "Your perfect partner",
            category: .people,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add an attractive AI girlfriend naturally beside the subject.",
            photographHint: "Chest-up or full-body in good lighting, relaxed pose.",
            exampleDescription: "A real-looking couple photo with your AI girlfriend"
        )
    ]

    static func templates(for category: TemplateCategory) -> [Template] {
        sampleTemplates.filter { $0.category == category }
    }
}

//
//  Template.swift
//  kivoai
//

import Foundation

struct TemplateStyleVariant: Identifiable, Hashable {
    let id: String
    let title: String
    let prompt: String
    let exampleImageName: String
}

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
    let styleVariants: [TemplateStyleVariant]

    init(
        id: String,
        title: String,
        subtitle: String,
        category: TemplateCategory,
        creditCost: Int,
        requiresPhoto: Bool,
        basePrompt: String,
        photographHint: String,
        exampleDescription: String,
        styleVariants: [TemplateStyleVariant] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.creditCost = creditCost
        self.requiresPhoto = requiresPhoto
        self.basePrompt = basePrompt
        self.photographHint = photographHint
        self.exampleDescription = exampleDescription
        self.styleVariants = styleVariants
    }

    static let sampleTemplates: [Template] = [

        // MARK: - PRANKS (6)

        Template(
            id: "prank_home_intruder",
            title: "Homeless Man",
            subtitle: "There's someone in your house...",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a realistic homeless man naturally present inside the home — sitting on the couch, standing in the kitchen, or lurking in the background. He should look disheveled with worn clothing, as if he wandered in.",
            photographHint: "Face the camera with some open space visible behind you.",
            exampleDescription: "A homeless man casually in your home like he lives there"
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

        // MARK: - APPEARANCE

        Template(
            id: "appearance_men_hair",
            title: "Men Hair",
            subtitle: "Pick your style",
            category: .appearance,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject a sharp buzz cut with a clean high skin fade.",
            photographHint: "Clear headshot, hair tied back or short, even lighting.",
            exampleDescription: "A fresh men's hair transformation",
            styleVariants: [
                TemplateStyleVariant(
                    id: "mens_hair_buzz_cut",
                    title: "Buzz Cut",
                    prompt: "Give the subject a sharp buzz cut with a clean high skin fade.",
                    exampleImageName: "style_mens_hair_buzz_cut"
                ),
                TemplateStyleVariant(
                    id: "mens_hair_mullet",
                    title: "Mullet",
                    prompt: "Give the subject a modern mullet — short on top, longer in the back, faded sides.",
                    exampleImageName: "style_mens_hair_mullet"
                )
            ]
        ),

        Template(
            id: "appearance_women_hair",
            title: "Women Hair",
            subtitle: "Pick your style",
            category: .appearance,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Give the subject long, pin-straight, ultra-glossy hair with a center part.",
            photographHint: "Clear headshot or chest-up, hair down, even lighting.",
            exampleDescription: "A stunning women's hair transformation",
            styleVariants: [
                TemplateStyleVariant(
                    id: "womens_hair_straight",
                    title: "Straight",
                    prompt: "Give the subject long, pin-straight, ultra-glossy hair with a center part.",
                    exampleImageName: "style_womens_hair_straight"
                ),
                TemplateStyleVariant(
                    id: "womens_hair_platinum_blonde",
                    title: "Platinum Blonde",
                    prompt: "Change the subject's hair to bright platinum blonde.",
                    exampleImageName: "style_womens_hair_platinum_blonde"
                ),
                TemplateStyleVariant(
                    id: "womens_hair_pixie_cut",
                    title: "Pixie Cut",
                    prompt: "Give the subject a sharp, textured pixie cut.",
                    exampleImageName: "style_womens_hair_pixie_cut"
                ),
                TemplateStyleVariant(
                    id: "womens_hair_hollywood",
                    title: "Hollywood",
                    prompt: "Give the subject a glamorous Hollywood blowout with voluminous silky waves.",
                    exampleImageName: "style_womens_hair_hollywood"
                )
            ]
        ),

        Template(
            id: "appearance_tattoos",
            title: "Tattoos",
            subtitle: "Pick your style",
            category: .appearance,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add scattered black patchwork tattoos with very uneven distribution, heavy clustering in some areas do not spread tattoos evenly. Random placement, varied angles, overlapping directions, inconsistent sizing (2–8 cm). Random subjects every generation (animals, words,myth, hands, symbols, abstract, geometric, micro objects). as if each done over time by different artists.",
            photographHint: "Bare arm in good lighting, from shoulder to wrist.",
            exampleDescription: "A bold tattoo transformation",
            styleVariants: [
                TemplateStyleVariant(
                    id: "tattoo_patchwork",
                    title: "Patchwork Tattoos",
                    prompt: "Add scattered black patchwork tattoos with very uneven distribution, heavy clustering in some areas do not spread tattoos evenly. Random placement, varied angles, overlapping directions, inconsistent sizing (2–8 cm). Random subjects every generation (animals, words,myth, hands, symbols, abstract, geometric, micro objects). as if each done over time by different artists.",
                    exampleImageName: "style_tattoo_patchwork"
                ),
                TemplateStyleVariant(
                    id: "tattoo_dragon_sleeve",
                    title: "Dragon Full Sleeve",
                    prompt: "Add a massive detailed dragon tattoo wrapping around the full arm in one cohesive black and grey sleeve.",
                    exampleImageName: "style_tattoo_dragon_sleeve"
                ),
                TemplateStyleVariant(
                    id: "tattoo_japanese_sleeve",
                    title: "Japanese Sleeve",
                    prompt: "Add a traditional Japanese Irezumi tattoo sleeve with koi fish, cherry blossoms, and waves.",
                    exampleImageName: "style_tattoo_japanese_sleeve"
                ),
                TemplateStyleVariant(
                    id: "tattoo_snake",
                    title: "Snake",
                    prompt: "dd a detailed snake tattoo coiling and wrapping around the forearm in a continuous, elegant flow. The snake should spiral around the arm, following its anatomy, with the head clearly visible as a focal point. ",
                    exampleImageName: "style_tattoo_snake"
                ),
                TemplateStyleVariant(
                    id: "tattoo_lion",
                    title: "Lion",
                    prompt: "Add a bold, hyper-realistic lion head tattoo on the upper arm as a single strong centerpiece. Place the lion so it faces outward or slightly angled, with intense eyes and detailed fur texture.",
                    exampleImageName: "style_tattoo_lion"
                )
            ]
        ),

        Template(
            id: "appearance_eyebrow_slit",
            title: "Eyebrow Slit",
            subtitle: "Sharp and edgy",
            category: .appearance,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a precise eyebrow slit cut to give a sharp, edgy look.",
            photographHint: "Close-up headshot with eyebrows clearly visible, even lighting.",
            exampleDescription: "A clean, precise eyebrow slit"
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
            title: "Japanese Animation",
            subtitle: "Soft, painterly, and magical",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a hand-painted Japanese animation character illustration with expressive eyes, soft linework, and a painterly background.",
            photographHint: "Clear headshot or waist-up, natural expression.",
            exampleDescription: "You as a character in a Japanese animated film"
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

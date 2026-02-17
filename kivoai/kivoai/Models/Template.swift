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
    let afterImageName: String

    init(id: String, title: String, prompt: String, exampleImageName: String, afterImageName: String = "") {
        self.id = id
        self.title = title
        self.prompt = prompt
        self.exampleImageName = exampleImageName
        self.afterImageName = afterImageName
    }
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
    let beforeImageName: String
    let afterImageName: String

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
        styleVariants: [TemplateStyleVariant] = [],
        beforeImageName: String = "",
        afterImageName: String = ""
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
        self.beforeImageName = beforeImageName
        self.afterImageName = afterImageName
    }

    static let sampleTemplates: [Template] = [

        // MARK: - PRANKS (6)

        Template(
            id: "prank_totaled_car",
            title: "Totaled Car",
            subtitle: "Uh oh... who did this?",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add severe crash damage — crumpled body panels, shattered windows, and debris.",
            photographHint: "Stand in front of or beside your car with it filling most of the frame.",
            exampleDescription: "Your car looking completely totaled after a crash",
            beforeImageName: "before_totaledcar",
            afterImageName: "after_totaledcar"
        ),

        Template(
            id: "prank_smashed_tv",
            title: "Smashed TV",
            subtitle: "The ultimate heart-attack prank",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Shatter the TV screen with a realistic crack.",
            photographHint: "Straight-on photo of your full TV. Turn it off for best results.",
            exampleDescription: "Your TV screen shattered into a million pieces",
            beforeImageName: "before_smashedtv",
            afterImageName: "after_smashedtv"
        ),

        Template(
            id: "prank_home_intruder",
            title: "Homeless Man",
            subtitle: "There's someone in your house...",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a realistic homeless man naturally present inside the home — sitting on the couch, standing in the kitchen, or lurking in the background. He should look disheveled with worn clothing, as if he wandered in.",
            photographHint: "Face the camera with some open space visible behind you.",
            exampleDescription: "A homeless man casually in your home like he lives there",
            beforeImageName: "before_homeless",
            afterImageName: "after_homeless"
        ),

        Template(
            id: "prank_smashed_windshield",
            title: "Smashed Windshield",
            subtitle: "Someone hit your car!",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a small, realistic windshield crack starting from a single impact point. Subtle fracture about 5–10 cm wide. Keep the rest of the glass intact. Natural transparency and light reflection.",
            photographHint: "Shoot forward through the windshield from the driver or passenger seat.",
            exampleDescription: "Your windshield smashed with a massive crack web",
            beforeImageName: "before_windshield",
            afterImageName: "after_windshield"
        ),

        Template(
            id: "prank_mugshot",
            title: "Mugshot",
            subtitle: "Breaking the internet",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Generate a realistic mugshot of the person wearing orange prison clothes. The photo should be cropped from head to upper chest.  The face should resemble the face from the uploaded photo. the expression should be serious and dramatic. The background should be a realistic prison.",
            photographHint: "Straight-on headshot against a plain wall, neutral expression, even lighting.",
            exampleDescription: "A dead-serious, totally believable police mugshot",
            beforeImageName: "before_mugshot",
            afterImageName: "after_mugshot"
        ),

        Template(
            id: "prank_grocery_cam",
            title: "Grocery Store Security Cam",
            subtitle: "Caught on camera",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Overhead grainy CCTV footage inside a grocery store, ceiling-mounted corner security camera looking sharply downward (top-down angle). Low-res, digital noise, compression artifacts, slight wide-angle lens distortion. Add 'CAM 04' overlay. Person looks suddenly shocked and tense, caught mid-suspicious act. Freeze-frame surveillance vibe.",
            photographHint: "Any store aisle or corridor. A slightly elevated angle looks most like surveillance.",
            exampleDescription: "You caught doing something suspicious on a store security cam",
            beforeImageName: "before_grocery",
            afterImageName: "after_grocery"
        ),

        // MARK: - APPEARANCE

        Template(
            id: "appearance_tattoos",
            title: "Tattoos",
            subtitle: "Pick your style",
            category: .appearance,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "dd sparse black patchwork tattoos on the arms but not hands or wrist with uneven distribution and obvious empty skin; avoid dense coverage. keep all existing clothing fully intact and unchanged. Use random placement, varied angles, overlapping directions, and 2–8 cm sizes so it feels unplanned, with mixed, unrelated subjects (animals, words, myth, hands, symbols, abstract, geometric, tiny objects) like work by many different artists over time.",
            photographHint: "Bare arm in good lighting, from shoulder to wrist.",
            exampleDescription: "A bold tattoo transformation",
            styleVariants: [
                TemplateStyleVariant(
                    id: "tattoo_patchwork",
                    title: "Patchwork Tattoos",
                    prompt: "Add sparse black patchwork tattoos on the arms but not hands or wrist with uneven distribution and obvious empty skin; avoid dense coverage. keep all existing clothing fully intact and unchanged. Use random placement, varied angles, overlapping directions, and 2–8 cm sizes so it feels unplanned, with mixed, unrelated subjects (animals, words, myth, hands, symbols, abstract, geometric, tiny objects) like work by many different artists over time.",
                    exampleImageName: "after_tattoo_patchwork",
                    afterImageName: "after_tattoo_patchwork"
                ),
                TemplateStyleVariant(
                    id: "tattoo_dragon_sleeve",
                    title: "Dragon Full Sleeve",
                    prompt: "Add a massive detailed dragon tattoo wrapping around the full arm in one cohesive black and grey sleeve.",
                    exampleImageName: "after_tattoo_dragon",
                    afterImageName: "after_tattoo_dragon"
                ),
                TemplateStyleVariant(
                    id: "tattoo_japanese_sleeve",
                    title: "Japanese Sleeve",
                    prompt: "Add a traditional Japanese Irezumi tattoo sleeve with koi fish, cherry blossoms, and waves.",
                    exampleImageName: "after_tattoo_japanese",
                    afterImageName: "after_tattoo_japanese"
                )
            ],
            beforeImageName: "before_tattoo",
            afterImageName: "after_tattoo_patchwork"
        ),

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
                    exampleImageName: "after_menhair_buzz",
                    afterImageName: "after_menhair_buzz"
                ),
                TemplateStyleVariant(
                    id: "mens_hair_mullet",
                    title: "Mullet",
                    prompt: "Give the subject a modern mullet — short on top, longer in the back, faded sides.",
                    exampleImageName: "after_menhair_mullet",
                    afterImageName: "after_menhair_mullet"
                )
            ],
            beforeImageName: "before_menhair",
            afterImageName: "after_menhair_buzz"
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
                    exampleImageName: "after_womenhair_straight",
                    afterImageName: "after_womenhair_straight"
                ),
                TemplateStyleVariant(
                    id: "womens_hair_platinum_blonde",
                    title: "Platinum Blonde",
                    prompt: "Change the subject's hair to bright platinum blonde.",
                    exampleImageName: "after_womenhair_blonde",
                    afterImageName: "after_womenhair_blonde"
                ),
                TemplateStyleVariant(
                    id: "womens_hair_pixie_cut",
                    title: "Pixie Cut",
                    prompt: "Give the subject a sharp, textured pixie cut.",
                    exampleImageName: "after_womenhair_pixiecut",
                    afterImageName: "after_womenhair_pixiecut"
                )
            ],
            beforeImageName: "before_womenhair",
            afterImageName: "after_womenhair_pixiecut"
        ),

        // MARK: - CARTOON (8)

        Template(
            id: "cartoon_action_figure",
            title: "Action Figure",
            subtitle: "Boxed and ready for the shelf",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Create a 1/7 scale commercialized figurine of the characters in the picture, in a realistic style, in a real environment. The figurine is placed on a computer desk. The figurine has a round transparent acrylic base, with no text on the base. The content on the computer screen is a 3D modeling process of this figurine. Next to the computer screen is a toy packaging box, designed in a style reminiscent of high-quality collectible figures, printed with original artwork.",
            photographHint: "Full-body photo, standing straight, plain background.",
            exampleDescription: "You as a boxed action figure on a store shelf",
            beforeImageName: "before_malecartoon",
            afterImageName: "after_actionfigure"
        ),

        Template(
            id: "cartoon_funko_pop",
            title: "Funko Pop",
            subtitle: "Vinyl collectible version of you",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Create a detailed 3D render of a chibi Funko Pop figure, strictly based on the provided reference photo. The figure should accurately reflect the person's appearance, hairstyle, attire, and characteristic style from the photo. High detail, studio lighting, photorealistic texture, pure white background.",
            photographHint: "Clear headshot or chest-up, face and outfit visible.",
            exampleDescription: "A detailed Funko Pop figure version of you",
            beforeImageName: "before_femalecartoon",
            afterImageName: "after_funkopop"
        ),

        Template(
            id: "cartoon_lego",
            title: "LEGO",
            subtitle: "Everything is awesome!",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a custom LEGO minifigure with a matching face and outfit.",
            photographHint: "Face and outfit clearly visible in the photo.",
            exampleDescription: "A custom LEGO minifigure version of you",
            beforeImageName: "before_malecartoon",
            afterImageName: "after_lego"
        ),

        Template(
            id: "cartoon_bratz",
            title: "Bratz Doll",
            subtitle: "Y2K glam, oversized everything",
            category: .cartoon,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform into a Bratz doll illustration with oversized head, glossy lips, and Y2K fashion.",
            photographHint: "Clear headshot or chest-up, any expression.",
            exampleDescription: "You as a glamorous, fashion-forward Bratz doll",
            beforeImageName: "before_femalecartoon",
            afterImageName: "after_bratz"
        ),

        // MARK: - FACE TRANSFORMATIONS (5)

        Template(
            id: "face_baby",
            title: "Baby Version",
            subtitle: "You, but tiny and adorable",
            category: .faceTransformations,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Transform the subject into an adorable baby version of themselves wearing baby clothes, make sure theres obvious similar features and change the background.",
            photographHint: "Clear straight-on headshot, even lighting, plain background.",
            exampleDescription: "An adorable baby version of your exact face",
            beforeImageName: "before_baby",
            afterImageName: "after_baby"
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
            exampleDescription: "A realistic look at yourself 20 years from now",
            beforeImageName: "before_oldify",
            afterImageName: "after_oldify"
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
            exampleDescription: "A realistic younger version of your face",
            beforeImageName: "before_youngify",
            afterImageName: "after_youngify"
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
            exampleDescription: "You in a photo with a famous celebrity",
            beforeImageName: "before_celebrity",
            afterImageName: "after_celebrity"
        ),

        Template(
            id: "people_ai_boyfriend",
            title: "AI Boyfriend",
            subtitle: "Your perfect partner",
            category: .people,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a boyfriend naturally beside the subject.",
            photographHint: "Chest-up or full-body in good lighting, relaxed pose.",
            exampleDescription: "A real-looking couple photo with your AI boyfriend",
            beforeImageName: "before_aiboyfriend",
            afterImageName: "after_aiboyfriend"
        ),

        Template(
            id: "people_ai_girlfriend",
            title: "AI Girlfriend",
            subtitle: "Your perfect partner",
            category: .people,
            creditCost: 10,
            requiresPhoto: true,
            basePrompt: "Add a girlfriend naturally beside the subject.",
            photographHint: "Chest-up or full-body in good lighting, relaxed pose.",
            exampleDescription: "A real-looking couple photo with your AI girlfriend",
            beforeImageName: "before_aigirlfriend",
            afterImageName: "after_aigirlfriend"
        )
    ]

    static func templates(for category: TemplateCategory) -> [Template] {
        sampleTemplates.filter { $0.category == category }
    }
}

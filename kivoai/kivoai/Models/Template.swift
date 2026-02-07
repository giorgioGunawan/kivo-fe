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
    let photographHint: String
    let exampleDescription: String
    
    static let sampleTemplates: [Template] = [
        // Pranks
        Template(
            id: "prank_mugshot",
            title: "Mugshot Madness",
            subtitle: "Turn yourself into a wanted criminal",
            category: .pranks,
            creditCost: 10,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            photographHint: "Take a clear front-facing photo",
            exampleDescription: "A realistic mugshot with booking number"
        ),
        Template(
            id: "prank_alien",
            title: "Alien Encounter",
            subtitle: "Get abducted by aliens in your photo",
            category: .pranks,
            creditCost: 15,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            photographHint: "Take a photo outdoors at night",
            exampleDescription: "UFO beam lifting you into the sky"
        ),
        Template(
            id: "prank_zombie",
            title: "Zombie Mode",
            subtitle: "Transform into a walking dead",
            category: .pranks,
            creditCost: 12,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            photographHint: "Take a close-up face photo",
            exampleDescription: "Realistic zombie transformation"
        ),
        
        // Fashion
        Template(
            id: "fashion_runway",
            title: "Runway Ready",
            subtitle: "Walk the runway in designer clothes",
            category: .fashion,
            creditCost: 20,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            photographHint: "Full body standing photo",
            exampleDescription: "You in haute couture on a Paris runway"
        ),
        Template(
            id: "fashion_magazine",
            title: "Magazine Cover",
            subtitle: "Be on the cover of Vogue",
            category: .fashion,
            creditCost: 25,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            photographHint: "Portrait photo with good lighting",
            exampleDescription: "Professional magazine cover shoot"
        ),
        
        // Relationships
        Template(
            id: "rel_celebrity",
            title: "Celebrity Date",
            subtitle: "Go on a date with any celebrity",
            category: .relationships,
            creditCost: 30,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            photographHint: "Side profile or 3/4 angle photo",
            exampleDescription: "Romantic dinner with your favorite star"
        ),
        Template(
            id: "rel_wedding",
            title: "Dream Wedding",
            subtitle: "Preview your dream wedding day",
            category: .relationships,
            creditCost: 35,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            photographHint: "Formal photo of yourself",
            exampleDescription: "Beautiful wedding ceremony scene"
        ),
        
        // Lifestyle
        Template(
            id: "life_billionaire",
            title: "Billionaire Life",
            subtitle: "Live the luxury lifestyle",
            category: .lifestyle,
            creditCost: 20,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            photographHint: "Casual or formal photo",
            exampleDescription: "You on a yacht with champagne"
        ),
        Template(
            id: "life_astronaut",
            title: "Space Explorer",
            subtitle: "Become an astronaut",
            category: .lifestyle,
            creditCost: 25,
            requiresPhoto: true,
            showsAdvancedPrompt: false,
            photographHint: "Front-facing photo",
            exampleDescription: "Floating in the International Space Station"
        ),
        Template(
            id: "life_athlete",
            title: "Pro Athlete",
            subtitle: "Score the winning goal",
            category: .lifestyle,
            creditCost: 18,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            photographHint: "Action pose photo",
            exampleDescription: "Celebrating a championship victory"
        ),
        
        // Other
        Template(
            id: "other_anime",
            title: "Anime Character",
            subtitle: "Transform into an anime hero",
            category: .other,
            creditCost: 15,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            photographHint: "Clear face photo",
            exampleDescription: "Studio Ghibli style character"
        ),
        Template(
            id: "other_vintage",
            title: "Time Traveler",
            subtitle: "Visit any era in history",
            category: .other,
            creditCost: 22,
            requiresPhoto: true,
            showsAdvancedPrompt: true,
            photographHint: "Any clear photo of yourself",
            exampleDescription: "You in 1920s New York"
        )
    ]
    
    static func templates(for category: TemplateCategory) -> [Template] {
        sampleTemplates.filter { $0.category == category }
    }
}

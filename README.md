CommonGround – AI-Powered Decision Support Platform
CommonGround is a Flutter-based AI system that helps citizens access public support services in an intelligent and transparent way.
It uses Google Gemini 1.5 Flash + Firebase + Clean Architecture to:
- Analyze user situations
- Detect hidden needs
- Match services intelligently
- Detect crisis cases and prioritize safety

Features
AI Needs Analysis
- Extracts explicit and hidden needs
- Provides reasoning + confidence score

Crisis Detection
- Detects emergencies (homelessness, violence, suicide risk)
- Immediately redirects to crisis support screen

Smart Matching Engine
- Rule-based + AI hybrid system
- Shows eligibility confidence and explanation

Organization Dashboard
- Manage services and eligibility rules
- Control capacity levels

Admin Dashboard
- Shows demand vs supply gaps
- Visual analytics charts

Multilingual Support
- English + Arabic
- Full RTL support

Tech Stack
- Flutter (Dart)
- Material 3
- Riverpod
- Firebase Auth
- Cloud Firestore
- Google Gemini 1.5 Flash
- fl_chart

 Architecture
Feature-Based Clean Architecture:
- core/
- features/auth
- features/citizen
- features/organization
- features/admin

Each feature has:
- data layer
- domain layer
- UI layer

Safety
- Human-in-the-loop design
- Crisis override system
- Transparent AI reasoning
- Non-deterministic AI results are explained

Built By
CommonGround Team

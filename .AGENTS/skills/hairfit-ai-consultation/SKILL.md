---
name: hairfit-ai-consultation
description: Manage and enhance the on-device AI face analysis, face shape classification, haircut recommendations, and the AI Haircut Handshake.
risk: low
source: workspace
---

# HairFit AI - On-Device AI Consultation & Face Analysis

## 1. Zero-Cost On-Device Vision Strategy

HairFit AI does not upload user face photos to any external cloud AI API. All face processing happens entirely on the client's mobile device via **Google ML Kit Face Mesh**.

### Key Advantages:
- **Zero latency**: Real-time bounding and mesh calculation.
- **Zero cost**: No monthly API bill for cloud computer vision.
- **Maximum Privacy**: Raw biometric camera pixels stay strictly on the user's phone.

---

## 2. Landmark Geometry & Face Shape Ratios

The system inspects key 3D landmark points calculated by Face Mesh:
1. **Face Length ($L$)**: Distance from top of forehead (landmark 10) to bottom of chin (landmark 152).
2. **Cheekbone Width ($W_{cheek}$)**: Distance between leftmost and rightmost zygomatic arches (landmarks 234 and 454).
3. **Forehead Width ($W_{forehead}$)**: Distance across upper temples (landmarks 103 and 332).
4. **Jawline Width ($W_{jaw}$)**: Distance across gonial angles of the jaw (landmarks 132 and 361).

### Classification Matrix:
- **Oval**: $L / W_{cheek} \approx 1.5$, $W_{forehead} > W_{jaw}$, softly rounded jawline.
- **Round**: $L / W_{cheek} \approx 1.0 - 1.2$, jaw and forehead curved and similar in width.
- **Square**: $L / W_{cheek} \approx 1.0 - 1.2$, sharp angle at gonial points, $W_{forehead} \approx W_{jaw}$.
- **Heart**: $W_{forehead} > W_{cheek} > W_{jaw}$, narrow and pointed chin.
- **Diamond**: $W_{cheek} > W_{forehead}$ and $W_{cheek} > W_{jaw}$, pointed chin and narrow forehead.
- **Oblong / Rectangle**: $L / W_{cheek} > 1.6$, forehead, cheekbones, and jawline of similar width.

---

## 3. Hairstyle Recommendation & Handshake Integration

1. **Recommendation Matching**:
   - Each face shape maps to proven haircut styles (e.g. Round -> Textured Quiff, Pompadour; Square -> Buzz Cut, Side Part, Undercut).
2. **Auto-Save**:
   - When analysis completes, `ai_consult_provider.dart` saves the analyzed `faceShape` to Firestore `users/{uid}` and caches it in `SharedPreferences`.
3. **AI Haircut Handshake Card**:
   - When the user books an appointment from the consultation screen, the selected haircut and face shape profile are embedded into `AppointmentModel.aiRecommendation`.
   - The barber sees this directly on the appointment card upon opening their app.

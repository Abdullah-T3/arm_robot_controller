# Arm 3D Model Specification (Real-Time, High Fidelity)

This document defines the technical and artistic requirements for a highly realistic human arm model suitable for real-time rendering on mobile and desktop.

## Geometry & Scale
- Real-world scale in meters; shoulder-to-fingertips ≈ 0.7 m.
- Polycount: 50,000–100,000 triangles total (LOD0). Provide LOD1 (~25–40k) and LOD2 (~10–20k) if possible.
- Topology: quad-dominant, deformation-friendly, edge loops around joints (shoulder, elbow, wrist, MCP, PIP, DIP).
- Separate meshes recommended for fingernails to control shading and thickness; maintain contiguous UVs if integrated.

## Anatomy & Rig
- Bones: `Clavicle`, `Scapula`, `Humerus`, `Ulna`, `Radius`, `Carpals`, `Metacarpals`, `ProximalPhalanges`, `IntermediatePhalanges`, `DistalPhalanges`.
- Shoulder articulation: clavicle/scapula glide and humeral rotation with realistic constraints.
- Elbow: hinge with slight ulna/radius behavior; forearm pronation/supination via radius over ulna.
- Wrist: flexion/extension, radial/ulnar deviation.
- Fingers: MCP (ball), PIP/DIP (hinge); realistic ranges per finger.
- Skinning: weight painting ensures smooth deformation; include twist bones for forearm and upper arm to avoid candy-wrapper artifacts.
- Corrective blend shapes for extreme poses (elbow bend, wrist flexion, finger curl).

## Textures (4K PBR)
- `Albedo/BaseColor` (4K, sRGB): subtle color variation, veins, freckles, blemishes.
- `Normal` (4K, linear): fine detail for pores, wrinkles; use high-res baked map.
- `Roughness` (4K, linear): varied micro-roughness across regions (palms vs dorsum).
- `Metallic` (4K, linear): zero except nails and accessories; use mask.
- `AmbientOcclusion` (4K, linear): baked.
- Optional detail normal (2K) tiled for micro-pores layered via shader.
- UVs: single UDIM or 0–1 with minimal seams; fingers arranged to reduce distortion.

## Materials & SSS
- Physical-based shading (`MeshPhysicalMaterial` or equivalent).
- Subsurface scattering approximation via transmission/thickness with appropriate IOR and scattering distance for soft tissue.
- Separate material set for fingernails: thinner transmission, higher roughness at cuticle, mild anisotropy.

## Dynamic Elements
- Micro-twitch idle animation (subtle muscle/skin motion, 0.2–0.5 mm amplitude).
- Secondary motion: slight jiggle on soft tissue and tendon sliding.
- Vein prominence blend shape or mask to vary vascularity.

## Export
- Format: GLTF/GLB with embedded textures (preferred GLB). Maintain bone names and animation clips.
- Coordinate system: Y up, meters scale, right-handed.
- Include separate animation clips: `Idle`, `FingerCurl`, `WristFlex`, `ElbowBend`, `PronationSupination`.
- Provide material parameters and environment recommendations (HDR).

## Acceptance Tests
- Inspect under multiple HDRI environments (studio, overcast, warm indoor).
- Check deformation quality across full ROM, no collapsing at joints.
- Confirm texture fidelity at 4K; pores/veins visible at typical hand distance.
- Verify performance: 60 FPS on modern mobile (Android ARMv8), stable memory.

## Delivery Checklist
- GLB file with PBR textures embedded.
- Source textures (PNG/TGA) and original baked maps.
- Documentation of bone names and animation clips.
- Screenshots/video from acceptance tests (lighting + poses).
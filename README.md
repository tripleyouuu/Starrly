# Starrly

Starrly is a macOS app that turns personal reflection into a living night sky. Instead of a flat list of notes, the things you record are represented as **stars** — they grow over time, cluster into **constellations**, and can be explored in an immersive, pannable 3D sky.

## Core concepts

- **Star** — the atomic unit of the app. A star has a type/lifecycle stage (protostar, dwarf star, giant star, supernova, neutron star) that reflects its growth over time.
- **Session** — an entry logged against a star (with a title, body text, and attached media), similar to a journal entry. Sessions are what cause a star to grow and evolve.
- **Constellation** — a named group of related stars, laid out and connected on a map so related stars can be viewed together.
- **Orbiting members** — stars/planets can have their own member bodies (e.g. planets orbiting a star), giving each star its own mini orbital map.

## Features

- **Home** — a dashboard with stats, a moon-phase panel (calculated from the current date), a "recently explored" panel, and a telescope-themed entry point into the sky.
- **Discovery flow** — a guided onboarding sequence for first-time use: naming your first constellation and your first star.
- **Explore** — an immersive, RealityKit-powered 3D sky scene (sky sphere, horizon, camera rig, billboarded stars) that can be panned and zoomed to browse the whole night sky of stars the user has created.
- **Constellation view** — a map of a constellation's member stars, with the ability to add new stars to it.
- **Star view** — a star's detail page, including an orbit map of its member bodies.
- **Session view** — the editor for an individual session's title, body, and media.

## Design & tech

- Built with **SwiftUI** and **SwiftData** for UI and persistence, targeting macOS 26+.
- **RealityKit** powers the 3D "Explore" sky scene.
- UI styling leans on a Liquid Glass–style presentation layer (shared glass materials, spotlight/hover effects, a pannable/zoomable canvas, and a media carousel) for a consistent, translucent visual language across screens.

## Project structure

```
Starrly/
├── App/            # App-wide state
├── Models/         # SwiftData models: Star, StarType, Constellation, Session
├── Persistence/     # Model container setup and media storage on disk
├── SkyEngine/       # Layout math for placing stars/constellations, moon phase calc, constellation line drawing
├── StarRendering/   # Visual representation of stars: color palettes, animation, shape assignment
├── Scene3D/         # RealityKit entities and camera/interaction logic for the Explore scene
├── Screens/         # Home, Discovery, Explore, ConstellationView, StarView, SessionView
├── Components/      # Shared UI building blocks (glass presets, overlays, carousel, canvas)
└── Resources/        # Onboarding copy and other static content
```

## Status

The project is in early scaffolding: the architecture and file structure above are in place, and most files currently contain their intended shape/purpose as stubs rather than full implementations.

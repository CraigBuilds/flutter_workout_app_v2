# flutter_workout_app_v2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## TODO

# High priority

- [ ] Save/Load Workout Templates
    - [ ] Backend support
        - [x] Add to database
        - [ ] Add CRUD methods to database
    - [ ] Make a UI Page or Dialog or this
- [ ] Improve the Add New / Edit Set Dialog, and make it compatible with all ExerciseSet fields (e.g forced reps, rest, etc)
    - [ ] The Dialog should have a row with "+Drop" buttons. Clicking the button reveals a place to add weight + reps for that drop.
- [ ] Display workoutName in HomePage Workout Card (The name can come from the template)
- [ ] Make it clear that the Workout Card (and all cards) can be long pressed.

# Low priority / long term goals

- [ ] Create Routines (auto create planned workouts from templates at regular intervals (e.g 3 day or 14 day cycles))
    - e.g 3 day: A → B → Rest (repeat)
    - e.g 14 day: A → Rest → B → Rest → A → Rest → Rest, B → Rest → A → Rest → B → Rest → Rest
- [ ] Duplicate Set (Copy/paste a previously made set)
- [ ] Advanced workout calendar showing decorations on dates with workouts / planned workouts
- [ ] Workout scheduling (using create new routine) - Look at Runna App for inspiration. Use a calendar plugin.
- [ ] Make it clear that you can scroll left and right in the home page. Perhaps a Runna style calendar bar at the top?
- [ ] Add a new home page, and rename the current home page to WorkoutCarousel 
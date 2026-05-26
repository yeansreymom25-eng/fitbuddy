# FitBuddy Presentation Slides

## Slide 1: FitBuddy Overview
- FitBuddy is a Flutter Android health companion app.
- It helps users track meals, water, sleep, exercise, reminders, and profile goals.
- Firebase Auth and Firestore keep each user account and health data private.

## Slide 2: Problem
- Many users want healthier habits but do not know what to eat each day.
- Generic meal plans do not respect goals, food preference, budget, or lifestyle.
- Tracking progress manually can feel confusing and inconsistent.

## Slide 3: Solution
- FitBuddy creates a daily meal plan based on the user profile.
- Users can track daily progress from one dashboard.
- The app now supports food preferences, budget, achievements, and feedback.

## Slide 4: Key Features
- Login, register, email verification, and logout with Firebase Auth.
- Personalized profile with goal, activity level, height, weight, and country.
- Daily meal plan with calories, nutrition, ingredients, and cooking steps.
- Progress tracking for meals, water, sleep, and exercise.

## Slide 5: New Improvements
- Modernized light UI theme with cleaner cards, buttons, and form controls.
- Food Preference screen saves diet style, protein choice, spice level, allergies, and avoided foods.
- Budget screen saves weekly food budget, currency, shopping style, and cooking time.
- Achievement & Feedback screen saves user rating, mood, and comments.

## Slide 6: Profile Image Upload
- Android gallery image picking is enabled.
- The app first tries Firebase Storage for profile photos.
- If Firebase Storage is unavailable, it saves a small Base64 profile image in Firestore.
- The Profile screen can display both Storage URLs and Base64 images.

## Slide 7: Meal Plan Personalization
- Future generated meal plans can use saved food preferences and budget.
- Vegetarian or tofu preference selects a vegetarian meal template.
- Low-cost budget adds budget-friendly meal labels and descriptions.
- Old saved meal plans are not changed automatically for safety.

## Slide 8: Technology and Future Work
- Built with Flutter for Android.
- Uses Firebase Auth, Cloud Firestore, Firebase Storage fallback, and Image Picker.
- Next steps: add Firebase Storage rules, richer achievements, better analytics, and optional meal regeneration.

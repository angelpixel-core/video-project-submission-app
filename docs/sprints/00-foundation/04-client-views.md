---
id: sprint-0-client-views
title: Client Views
phase: sprint-0
order: 4
aliases: []
tags:
  - sprint-0
  - ui
  - views
---

# Client Views

## Project Index View

- [x] Show a list of the client's existing projects.
- [x] Add a link to the Order Project view.

## Order Project View

- [x] Display a list or grid of available video types with prices.
- [x] Allow the customer to add multiple video type selections to the cart.
- [x] Let the client name the project.
- [x] Let the client supply a link to the raw footage.
- [x] Include a Pay button that opens a payment modal.
- [x] The modal collects payment details and shows the total due.

## Submission Behavior

- [x] Create the new Project for the client.
- [x] Persist the selected video types as `VideoTypeSelection` records.
- [x] Assign the default PM.
- [x] Change project status to Pending after submission.
- [x] Create a background Notification for the PM.
- [x] Redirect to the project index.

## PM Review

- [ ] PM acceptance moves the project from `pending` to `in_progress`.
- [ ] PM completion moves the project from `in_progress` to `completed`.

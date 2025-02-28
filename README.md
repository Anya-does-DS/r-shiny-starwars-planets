# 🌌 Star Wars Planets: Where Characters Come From?

This is a **Shiny app** that visualizes the **home planets of Star Wars characters**. The app allows you to explore character origins across different Star Wars movies in a **dynamic, interactive visualization**.

## 🚀 **Features**
- 🔍 **Interactive Planet Map:** Shows home planets of characters in a **bubble chart**.
- 🎥 **Movie Selection:** Choose **one** movie or **cumulatively add movies** to see planetary changes.
- 🌌 **Dark Theme:** Inspired by Star Wars aesthetics with a **sleek, glowing UI**.
- 📊 **Plotly Interactivity:** Hover over planets to reveal **character counts**.

## 📦 **Dependencies**
The following **R libraries** are required for this app:

| Library        | Purpose |
|---------------|---------|
| **shiny**     | Core framework for creating **interactive web apps** in R. |
| **dplyr**     | Data manipulation: filtering, grouping, and summarizing datasets. |
| **ggplot2**   | Creating **visualizations**, used for plotting the planet bubbles. |
| **tidyr**     | Helps in **reshaping and cleaning** data for plotting. |
| **stringr**   | Used for **string manipulation** (e.g., cleaning text data). |
| **plotly**    | Makes plots **interactive** (hover tooltips, zooming, etc.). |
| **packcircles** | Used for **circle packing**, ensuring planets don’t overlap. |
| **bslib**     | Provides **modern theming**, used to create the **dark Star Wars theme**. |
| **viridis**   | Creates a **colorblind-friendly** palette for planet visualization. |

## 🛠 **Installation & Usage**
### 1️⃣ Clone the Repository
```sh
git clone https://github.com/Anya-does-DS/r-shiny-starwars-planets.git
cd r-shiny-starwars-planets

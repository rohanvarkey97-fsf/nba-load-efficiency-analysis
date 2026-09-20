import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv('curry_load_analysis.csv')  # place the CSV alongside this script, or adjust the path

seasons = ['2022-23', '2023-24', '2024-25', '2025-26']
colors = {
    '2022-23': '#1f77b4',  # blue
    '2023-24': '#ff7f0e',  # orange
    '2024-25': '#2ca02c',  # green
    '2025-26': '#d62728',  # red
}

fig, ax = plt.subplots(figsize=(12, 8))

for season in seasons:
    season_df = df[df['season'] == season].sort_values('cumulative_minutes')
    x = season_df['cumulative_minutes'].values
    y = season_df['true_shooting_pct'].values

    ax.scatter(x, y, color=colors[season], alpha=0.55, s=35, label=season, edgecolor='none')

    if len(x) >= 2:
        coeffs = np.polyfit(x, y, 1)
        trend_x = np.linspace(x.min(), x.max(), 100)
        trend_y = np.polyval(coeffs, trend_x)
        ax.plot(trend_x, trend_y, color=colors[season], linewidth=2.2, linestyle='-')

        slope_per_1000 = coeffs[0] * 1000
        ax.annotate(f'{season}: {slope_per_1000:+.3f} TS%/1000min',
                    xy=(trend_x[-1], trend_y[-1]),
                    xytext=(6, 0), textcoords='offset points',
                    fontsize=8, color=colors[season], fontweight='bold',
                    va='center')

ax.axvline(x=1000, color='gray', linestyle='--', linewidth=1.3, alpha=0.7)
ax.text(1000, ax.get_ylim()[1], ' 1,000 min\n (exploratory\n threshold)',
        fontsize=8, color='dimgray', ha='left', va='top', style='italic')

ax.set_title("Steph Curry — Cumulative Minutes vs True Shooting % by Season",
             fontsize=14, fontweight='bold', pad=15)
ax.set_xlabel("Cumulative Minutes (within season)", fontsize=11)
ax.set_ylabel("True Shooting %", fontsize=11)
ax.grid(axis='both', linestyle='--', alpha=0.3)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.legend(title='Season', loc='upper right', fontsize=9)

fig.text(0.5, -0.06,
         "Note: a linear model across all four seasons (cumulative minutes × season) explains only "
         "2.7% of variance in single-game TS% (R²=0.027) and is not statistically significant (p=0.55). "
         "Single-game efficiency is dominated by game-to-game noise rather than a detectable load effect — "
         "the rolling-average (Viz 1) and season-thirds (Viz 2) views are the more reliable signal.",
         ha='center', fontsize=8.5, style='italic', color='dimgray', wrap=True)

plt.tight_layout()
plt.savefig('viz3_cumulative_minutes_vs_ts.png', dpi=300, bbox_inches='tight')
plt.show()
print("Saved")

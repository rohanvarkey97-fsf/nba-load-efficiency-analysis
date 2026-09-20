import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

df = pd.read_csv('curry_load_analysis.csv')  # place the CSV alongside this script, or adjust the path

seasons = ['2022-23', '2023-24', '2024-25', '2025-26']
fig, axes = plt.subplots(1, 4, figsize=(20, 5))
fig.suptitle("Steph Curry — Rolling Load vs Rolling Efficiency by Season", 
             fontsize=14, fontweight='bold', y=1.02)

for i, season in enumerate(seasons):
    ax1 = axes[i]
    ax2 = ax1.twinx()
    
    season_df = df[df['season'] == season].reset_index(drop=True)
    
    ax1.plot(season_df['healthy_game_number'], 
             season_df['rolling_5_avg_minutes'],
             color='steelblue', linewidth=2, label='Rolling 5-game avg minutes')
    
    ax2.plot(season_df['healthy_game_number'],
             season_df['rolling_5_ts_pct'],
             color='darkorange', linewidth=2, label='Rolling 5-game TS%')
    
    max_game = season_df['healthy_game_number'].max()
    ax1.axvspan(21, min(40, max_game), alpha=0.1, color='red', label='Second third')
    
    ax1.set_title(f"{season}", fontsize=12, fontweight='bold')
    ax1.set_xlabel("Healthy game number", fontsize=10)
    ax1.set_ylabel("Avg minutes", color='steelblue', fontsize=10)
    ax2.set_ylabel("Rolling TS%", color='darkorange', fontsize=10)
    ax1.set_ylim(20, 45)
    ax2.set_ylim(0.4, 0.9)
    ax1.tick_params(axis='y', labelcolor='steelblue')
    ax2.tick_params(axis='y', labelcolor='darkorange')
    
    if season == '2025-26':
        ax1.text(0.98, 0.98, 'Season ended\nearly (injury)', 
                 transform=ax1.transAxes,
                 fontsize=8, ha='right', va='top',
                 color='red', style='italic')

blue_line = plt.Line2D([0], [0], color='steelblue', linewidth=2, label='Rolling 5-game avg minutes')
orange_line = plt.Line2D([0], [0], color='darkorange', linewidth=2, label='Rolling 5-game TS%')
red_patch = mpatches.Patch(color='red', alpha=0.2, label='Second third (games 21-40)')
fig.legend(handles=[blue_line, orange_line, red_patch], 
           loc='lower center', ncol=3, bbox_to_anchor=(0.5, -0.05))

plt.tight_layout()
plt.savefig('viz1_rolling_load_vs_efficiency.png', dpi=300, bbox_inches='tight')
plt.show()
print("Saved")

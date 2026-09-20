import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv('curry_load_analysis.csv')  # place the CSV alongside this script, or adjust the path

summary = (
    df.groupby(['season', 'season_third'])
      .agg(avg_minutes=('total_minutes', 'mean'),
           avg_ts=('true_shooting_pct', 'mean'),
           avg_3p=('three_point_pct', 'mean'),
           n_games=('healthy_game_number', 'count'))
      .reset_index()
)

seasons = ['2022-23', '2023-24', '2024-25', '2025-26']
thirds = ['First third', 'Second third', 'Final third']
colors = {'First third': 'steelblue', 'Second third': 'darkorange', 'Final third': 'seagreen'}

metrics = [
    ('avg_minutes', 'Avg Minutes', (25, 38), '{:.1f}'),
    ('avg_ts',      'Avg TS%',     (0.50, 0.72), '{:.1%}'),
    ('avg_3p',      'Avg 3P%',     (0.30, 0.48), '{:.1%}'),
]

fig, axes = plt.subplots(1, 3, figsize=(20, 6))
fig.suptitle("Steph Curry — Season Thirds Comparison (2022–2026)",
             fontsize=14, fontweight='bold', y=1.03)

bar_width = 0.25
x = np.arange(len(seasons))

for ax, (col, label, ylim, fmt) in zip(axes, metrics):
    for i, third in enumerate(thirds):
        vals, n_games = [], []
        for s in seasons:
            row = summary[(summary['season'] == s) & (summary['season_third'] == third)]
            vals.append(row[col].values[0] if not row.empty else np.nan)
            n_games.append(row['n_games'].values[0] if not row.empty else 0)

        x_pos = x + (i - 1) * bar_width
        bars = ax.bar(x_pos, vals, bar_width, label=third,
                       color=colors[third], edgecolor='black', linewidth=0.6)

        for bx, v in zip(x_pos, vals):
            if not np.isnan(v):
                ax.annotate(fmt.format(v), (bx, v),
                            textcoords="offset points", xytext=(0, 3),
                            ha='center', va='bottom', fontsize=8, fontweight='bold')

        for bx, v, n in zip(x_pos, vals, n_games):
            if not np.isnan(v) and n < 10:
                ax.annotate(f'⚠ n={n}', (bx, v),
                            textcoords="offset points", xytext=(0, 16),
                            ha='center', fontsize=7, color='red')

        if third == 'Second third':
            for bx, v in zip(x_pos, vals):
                if not np.isnan(v):
                    ax.annotate('trough', (bx, v),
                                textcoords="offset points", xytext=(0, -14),
                                ha='center', fontsize=7, color='darkorange',
                                fontweight='bold')

    ax.set_title(label, fontsize=12, fontweight='bold')
    ax.set_ylim(ylim)
    ax.set_xticks(x)
    ax.set_xticklabels(seasons)
    ax.set_ylabel(label, fontsize=10)
    ax.grid(axis='y', linestyle='--', alpha=0.4)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

axes[0].legend(title='Season Third', loc='upper right', fontsize=8)

fig.text(0.5, -0.06,
         "Note: the 2025-26 second-third \"trough\" is a 0.4pp gap (0.623 → 0.619), "
         "far smaller than the 5–7pp gaps seen in 2022-23, 2023-24, and 2024-25 — "
         "treat it as marginal, not a confirmed trough, given the season's abbreviated length.",
         ha='center', fontsize=8.5, style='italic', color='dimgray', wrap=True)

plt.tight_layout()
plt.savefig('viz2_season_thirds_comparison.png', dpi=300, bbox_inches='tight')
plt.show()
print("Saved")

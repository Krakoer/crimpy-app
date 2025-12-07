#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Debug script for Critical Force analysis.
Usage: python debug_critical_force.py <json_file_path> [load_time] [rest_time]

Default values:
- load_time: 7.0 seconds
- rest_time: 3.0 seconds
- threshold: 3.0 kg
"""

import json
import sys
from datetime import datetime
from typing import List, Tuple, Dict
import statistics
import matplotlib.pyplot as plt

class CriticalForceResults:
    def __init__(self, tmeans: List[float], fmeans: List[float], e_fmeans: List[float],
                 critical_load: float, load_asymptote: float, predicted_force: List[float]):
        self.tmeans = tmeans
        self.fmeans = fmeans
        self.e_fmeans = e_fmeans
        self.critical_load = critical_load
        self.load_asymptote = load_asymptote
        self.predicted_force = predicted_force


def load_data(json_file_path: str) -> Tuple[List[float], List[float]]:
    """Load data from JSON file and return time and force arrays."""
    print(f"Loading data from: {json_file_path}")
    
    # Try different encodings
    encodings = ['utf-8', 'utf-16', 'utf-16-le', 'cp1252', 'latin1']
    data = None
    
    for encoding in encodings:
        try:
            with open(json_file_path, 'r', encoding=encoding) as f:
                data = json.load(f)
            print(f"SUCCESS: File loaded with {encoding} encoding")
            break
        except Exception as e:
            print(f"ATTEMPT: Failed with {encoding}: {e}")
            continue
    
    if data is None:
        print("ERROR: Could not load file with any supported encoding")
        sys.exit(1)
    
    if not isinstance(data, list):
        print(f"ERROR: Expected JSON array, got {type(data)}")
        sys.exit(1)
    
    print(f"SUCCESS: Loaded {len(data)} data points")
    
    # Parse timestamps and values
    times = []
    forces = []
    start_time = None
    
    for i, point in enumerate(data):
        if not isinstance(point, dict) or 'value' not in point or 'timestamp' not in point:
            print(f"ERROR: Invalid data point at index {i}: {point}")
            continue
            
        try:
            # Parse timestamp
            timestamp_str = point['timestamp']
            timestamp = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
            
            if start_time is None:
                start_time = timestamp
            
            # Convert to seconds from start
            time_seconds = (timestamp - start_time).total_seconds()
            if time_seconds >= 9.5:
                times.append(time_seconds)
                forces.append(float(point['value']))
            
        except Exception as e:
            print(f"ERROR: Parsing data point {i}: {e}")
            continue
    
    if len(times) == 0:
        print("ERROR: No valid data points found")
        sys.exit(1)
    
    print(f"SUCCESS: Parsed {len(times)} valid data points")
    print(f"DATA: Time range: {times[0]:.2f}s to {times[-1]:.2f}s (duration: {times[-1] - times[0]:.2f}s)")
    print(f"DATA: Force range: {min(forces):.2f} to {max(forces):.2f} kg")
    print(f"DATA: Mean force: {statistics.mean(forces):.2f} kg")
    
    return times, forces


def get_raising_edges_index(forces: List[float], threshold: float = 3.0) -> List[int]:
    """Find indices where force crosses above threshold (raising edges)."""
    raising_edges = []
    for i in range(1, len(forces)):
        if forces[i] > threshold and forces[i-1] <= threshold:
            raising_edges.append(i)
    return raising_edges


def get_falling_edges_index(forces: List[float], threshold: float = 3.0) -> List[int]:
    """Find indices where force crosses below threshold (falling edges)."""
    falling_edges = []
    for i in range(1, len(forces)):
        if forces[i] <= threshold and forces[i-1] > threshold:
            falling_edges.append(i)
    return falling_edges


def sigma_clipped_stats(data: List[float], max_iterations: int = 5) -> Tuple[float, float, float]:
    """Calculate sigma-clipped statistics (mean, median, std)."""
    if not data:
        return 0.0, 0.0, 0.0
    
    mask = [True] * len(data)
    
    for iteration in range(max_iterations):
        masked_data = [data[i] for i in range(len(data)) if mask[i]]
        if not masked_data:
            break
            
        mean_val = statistics.mean(masked_data)
        std_val = statistics.stdev(masked_data) if len(masked_data) > 1 else 0.0
        
        # Update mask - keep points within 4 sigma
        new_mask = []
        for i in range(len(data)):
            new_mask.append(abs(data[i] - mean_val) < 4 * std_val)
        
        if new_mask == mask:  # Convergence
            break
        mask = new_mask
    
    final_data = [data[i] for i in range(len(data)) if mask[i]]
    if not final_data:
        return 0.0, 0.0, 0.0
    
    mean_val = statistics.mean(final_data)
    median_val = statistics.median(final_data)
    std_val = statistics.stdev(final_data) if len(final_data) > 1 else 0.0
    
    return mean_val, median_val, std_val


def measure_mean_loads(times: List[float], forces: List[float], threshold: float = 3.0) -> Dict[str, List[float]]:
    """Measure mean loads for each interval above threshold."""
    print(f"\nANALYSIS: Finding intervals above {threshold} kg threshold...")
    
    raising_edges = get_raising_edges_index(forces, threshold)
    falling_edges = get_falling_edges_index(forces, threshold)
    
    print(f"EDGES: Found {len(raising_edges)} raising edges at indices: {raising_edges}")
    print(f"EDGES: Found {len(falling_edges)} falling edges at indices: {falling_edges}")
    
    # Handle case where measurement stopped during a hang
    if len(raising_edges) == len(falling_edges) + 1:
        falling_edges.append(len(forces) - 1)
        print(f"WARNING: Added final falling edge at index {len(forces) - 1} (measurement stopped during hang)")
    
    if len(raising_edges) != len(falling_edges):
        print(f"ERROR: Mismatch: {len(raising_edges)} raising edges vs {len(falling_edges)} falling edges")
        return {}
    
    mean_loads = []
    durations = []
    median_loads = []
    mean_times = []
    
    print(f"\nINTERVALS: Analyzing each hang interval:")
    print(f"{'#':<3} {'Start':<6} {'End':<6} {'Duration':<10} {'Mean':<8} {'Median':<8} {'Std':<8}")
    print("-" * 60)
    
    for i in range(len(raising_edges)):
        start_idx = raising_edges[i]
        end_idx = falling_edges[i]
        
        if start_idx >= end_idx:
            print(f"ERROR: Invalid interval {i}: start {start_idx} >= end {end_idx}")
            continue
        
        duration = times[end_idx] - times[start_idx]
        interval_forces = forces[start_idx:end_idx]
        
        if not interval_forces:
            print(f"ERROR: Empty interval {i}")
            continue
        
        mean_val, median_val, std_val = sigma_clipped_stats(interval_forces)
        mean_time = (times[start_idx] + times[end_idx]) / 2
        
        mean_loads.append(mean_val)
        durations.append(duration)
        median_loads.append(median_val)
        mean_times.append(mean_time)
        
        print(f"{i+1:<3} {start_idx:<6} {end_idx:<6} {duration:<10.2f} {mean_val:<8.2f} {median_val:<8.2f} {std_val:<8.2f}")
    
    print(f"\nSUCCESS: Analyzed {len(mean_loads)} intervals")
    
    return {
        'mean_times': mean_times,
        'durations': durations,
        'mean_loads': mean_loads,
        'median_loads': median_loads
    }


def analyze_critical_force(times: List[float], forces: List[float], 
                          load_time: float, rest_time: float, threshold: float = 3.0) -> CriticalForceResults:
    """Perform critical force analysis with detailed debugging."""
    print(f"\nCRITICAL FORCE: Starting analysis")
    print(f"PARAMS: load_time={load_time}s, rest_time={rest_time}s, threshold={threshold}kg")
    
    # Measure mean loads for each interval
    results = measure_mean_loads(times, forces, threshold)
    
    if not results or not results['mean_loads']:
        print("ERROR: No valid intervals found - cannot perform analysis")
        return CriticalForceResults([], [], [], 0.0, 0.0, [])
    
    tmeans = results['mean_times']
    durations = results['durations']
    fmeans = results['mean_loads']
    
    print(f"\nSUMMARY: Analysis data:")
    print(f"   Number of intervals: {len(fmeans)}")
    print(f"   Mean forces: {[f'{f:.2f}' for f in fmeans]}")
    print(f"   Durations: {[f'{d:.2f}' for d in durations]}")
    
    if len(fmeans) < 5:
        print(f"WARNING: Only {len(fmeans)} intervals found, need at least 5 for reliable analysis")
    
    # Calculate load asymptote (mean of last 4 intervals)
    if len(fmeans) >= 5:
        last_four = fmeans[-5:-1]  # Last 4 intervals (excluding the very last)
        load_asymptote = statistics.mean(last_four)
        e_load_asymptote = statistics.stdev(last_four) / len(last_four) if len(last_four) > 1 else 0.0
        print(f"ASYMPTOTE: Load asymptote: {load_asymptote:.2f} +/- {e_load_asymptote:.3f} kg (from intervals {len(fmeans)-4} to {len(fmeans)-1})")
    else:
        load_asymptote = statistics.mean(fmeans)
        e_load_asymptote = 0.0
        print(f"WARNING: Using mean of all intervals as load asymptote: {load_asymptote:.2f} kg")
    
    # Calculate critical load
    factor = load_time / (load_time + rest_time)
    critical_load = load_asymptote * factor
    e_critical_load = critical_load * (e_load_asymptote / load_asymptote) if load_asymptote != 0 else 0.0
    
    print(f"CRITICAL LOAD:")
    print(f"   Factor: {factor:.3f} (load_time / (load_time + rest_time))")
    print(f"   Critical load: {critical_load:.2f} +/- {e_critical_load:.3f} kg")
    
    # Calculate W' (work capacity) model
    print(f"\nW' MODEL: Work capacity analysis:")
    used_in_each_interval = []
    remaining = []
    
    for i in range(len(fmeans)):
        # Work used in this interval
        used = (fmeans[i] - critical_load) * durations[i] - critical_load * (load_time + rest_time - durations[i])
        used_in_each_interval.append(used)
        
        # Cumulative remaining capacity
        remaining_val = used
        if i > 0:
            remaining_val += remaining[i-1]
        remaining.append(remaining_val)
        
        print(f"   Interval {i+1}: Force={fmeans[i]:.2f}kg, Duration={durations[i]:.2f}s, Used={used:.2f}, Remaining={remaining_val:.2f}")
    
    # Calculate alternative W'
    w_prime_alt = sum(remaining)
    print(f"   W' alternative: {w_prime_alt:.2f}")
    
    # Calculate alpha (recovery rate)
    if remaining and all(r != 0 for r in remaining):
        alpha_values = [(fmeans[i] - load_asymptote) / remaining[i] for i in range(len(fmeans))]
        alpha = statistics.median(alpha_values)
        print(f"   Alpha (recovery rate): {alpha:.6f}")
        print(f"   Alpha values: {[f'{a:.6f}' for a in alpha_values]}")
    else:
        alpha = 0.0
        print(f"   Alpha: 0.0 (cannot calculate - zero remaining values)")
    
    # Generate predicted forces
    predicted_force = []
    for i in range(len(remaining)):
        pred = load_asymptote + alpha * remaining[i]
        predicted_force.append(pred)
    
    print(f"\nFINAL RESULTS:")
    print(f"   Critical Load: {critical_load:.2f} kg")
    print(f"   Load Asymptote: {load_asymptote:.2f} kg")
    print(f"   Number of intervals analyzed: {len(fmeans)}")
    
    return CriticalForceResults(
        tmeans=tmeans,
        fmeans=fmeans,
        e_fmeans=[],  # Not calculated in this simplified version
        critical_load=critical_load,
        load_asymptote=load_asymptote,
        predicted_force=predicted_force
    )


def create_plots(times: List[float], forces: List[float], results: CriticalForceResults, threshold: float = 3.0):
    """Create diagnostic plots for the critical force analysis."""
    print("\nPLOTTING: Creating diagnostic plots...")
    
    # Create figure with subplots
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('Critical Force Analysis Debug Plots', fontsize=16, fontweight='bold')
    
    # Plot 1: Raw force data with threshold
    ax1.plot(times, forces, 'b-', linewidth=1, alpha=0.7, label='Force data')
    ax1.axhline(y=threshold, color='r', linestyle='--', alpha=0.8, label=f'Threshold ({threshold} kg)')
    if results.critical_load > 0:
        ax1.axhline(y=results.critical_load, color='g', linestyle='--', alpha=0.8, label=f'Critical Load ({results.critical_load:.2f} kg)')
        ax1.axhline(y=results.load_asymptote, color='orange', linestyle='--', alpha=0.8, label=f'Load Asymptote ({results.load_asymptote:.2f} kg)')
    ax1.set_xlabel('Time (s)')
    ax1.set_ylabel('Force (kg)')
    ax1.set_title('Force vs Time')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Mean loads per interval
    if results.fmeans:
        interval_numbers = list(range(1, len(results.fmeans) + 1))
        ax2.scatter(interval_numbers, results.fmeans, color='blue', s=50, alpha=0.7, label='Mean loads')
        ax2.plot(interval_numbers, results.fmeans, 'b-', alpha=0.5)
        if results.critical_load > 0:
            ax2.axhline(y=results.critical_load, color='g', linestyle='--', alpha=0.8, label=f'Critical Load ({results.critical_load:.2f} kg)')
            ax2.axhline(y=results.load_asymptote, color='orange', linestyle='--', alpha=0.8, label=f'Load Asymptote ({results.load_asymptote:.2f} kg)')
        ax2.set_xlabel('Interval #')
        ax2.set_ylabel('Mean Force (kg)')
        ax2.set_title('Mean Force per Interval')
        ax2.legend()
        ax2.grid(True, alpha=0.3)
    else:
        ax2.text(0.5, 0.5, 'No intervals found', ha='center', va='center', transform=ax2.transAxes, fontsize=14)
        ax2.set_title('Mean Force per Interval (No Data)')
    
    # Plot 3: Force distribution histogram
    ax3.hist(forces, bins=50, alpha=0.7, color='skyblue', edgecolor='black')
    ax3.axvline(x=threshold, color='r', linestyle='--', alpha=0.8, label=f'Threshold ({threshold} kg)')
    if results.critical_load > 0:
        ax3.axvline(x=results.critical_load, color='g', linestyle='--', alpha=0.8, label=f'Critical Load ({results.critical_load:.2f} kg)')
        ax3.axvline(x=results.load_asymptote, color='orange', linestyle='--', alpha=0.8, label=f'Load Asymptote ({results.load_asymptote:.2f} kg)')
    ax3.set_xlabel('Force (kg)')
    ax3.set_ylabel('Frequency')
    ax3.set_title('Force Distribution')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    
    # Plot 4: Predicted vs Actual (if we have predictions)
    if results.fmeans and results.predicted_force and len(results.predicted_force) == len(results.fmeans):
        ax4.scatter(results.fmeans, results.predicted_force, color='red', s=50, alpha=0.7, label='Predicted vs Actual')
        # Perfect prediction line
        min_val = min(min(results.fmeans), min(results.predicted_force))
        max_val = max(max(results.fmeans), max(results.predicted_force))
        ax4.plot([min_val, max_val], [min_val, max_val], 'k--', alpha=0.5, label='Perfect prediction')
        ax4.set_xlabel('Actual Mean Force (kg)')
        ax4.set_ylabel('Predicted Force (kg)')
        ax4.set_title('Model Prediction Quality')
        ax4.legend()
        ax4.grid(True, alpha=0.3)
    else:
        ax4.text(0.5, 0.5, 'No prediction data\navailable', ha='center', va='center', transform=ax4.transAxes, fontsize=14)
        ax4.set_title('Model Prediction Quality (No Data)')
    
    # Adjust layout and save
    plt.tight_layout()
    
    # Save plot
    plot_filename = 'critical_force_debug_plots.png'
    plt.savefig(plot_filename, dpi=300, bbox_inches='tight')
    print(f"PLOTTING: Saved diagnostic plots to {plot_filename}")
    
    # Show plot
    plt.show()


def create_detailed_analysis_plot(times: List[float], forces: List[float], results: CriticalForceResults, threshold: float = 3.0):
    """Create a detailed single plot showing all analysis components."""
    if not results.fmeans:
        print("PLOTTING: No data available for detailed analysis plot")
        return
        
    print("\nPLOTTING: Creating detailed analysis plot...")
    
    # Create single detailed plot
    plt.figure(figsize=(12, 8))
    
    # Plot raw force data
    plt.plot(times, forces, 'lightblue', linewidth=1, alpha=0.6, label='Raw force data')
    
    # Plot threshold line
    plt.axhline(y=threshold, color='red', linestyle='--', alpha=0.8, linewidth=2, label=f'Threshold ({threshold} kg)')
    
    # Plot critical load and load asymptote
    if results.critical_load > 0:
        plt.axhline(y=results.critical_load, color='green', linestyle='-', linewidth=2, label=f'Critical Load ({results.critical_load:.2f} kg)')
        plt.axhline(y=results.load_asymptote, color='orange', linestyle='-', linewidth=2, label=f'Load Asymptote ({results.load_asymptote:.2f} kg)')
    
    # Highlight intervals and plot mean values
    if results.tmeans and results.fmeans:
        # Get raising and falling edges to highlight intervals
        raising_edges = get_raising_edges_index(forces, threshold)
        falling_edges = get_falling_edges_index(forces, threshold)
        
        if len(raising_edges) == len(falling_edges) + 1:
            falling_edges.append(len(forces) - 1)
        
        # Highlight each interval
        for i in range(min(len(raising_edges), len(falling_edges))):
            start_idx = raising_edges[i]
            end_idx = falling_edges[i]
            start_time = times[start_idx]
            end_time = times[end_idx]
            
            # Highlight interval background
            plt.axvspan(start_time, end_time, alpha=0.2, color='yellow', label='Hang intervals' if i == 0 else '')
            
            # Plot mean value as horizontal line within interval
            plt.hlines(results.fmeans[i], start_time, end_time, colors='blue', linewidth=3, alpha=0.8)
            
            # Add text annotation for interval number
            mid_time = (start_time + end_time) / 2
            plt.annotate(f'{i+1}', xy=(mid_time, results.fmeans[i]), xytext=(5, 5), 
                        textcoords='offset points', fontsize=10, fontweight='bold',
                        bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))
    
    plt.xlabel('Time (s)', fontsize=12)
    plt.ylabel('Force (kg)', fontsize=12)
    plt.title('Critical Force Analysis - Detailed View', fontsize=14, fontweight='bold')
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.grid(True, alpha=0.3)
    
    # Adjust layout and save
    plt.tight_layout()
    
    # Save plot
    plot_filename = 'critical_force_detailed_analysis.png'
    plt.savefig(plot_filename, dpi=300, bbox_inches='tight')
    print(f"PLOTTING: Saved detailed analysis plot to {plot_filename}")
    
    # Show plot
    plt.show()


def main():
    if len(sys.argv) < 2:
        print("Usage: python debug_critical_force.py <json_file_path> [load_time] [rest_time]")
        print("Default: load_time=7.0s, rest_time=3.0s")
        sys.exit(1)
    
    json_file_path = sys.argv[1]
    load_time = float(sys.argv[2]) if len(sys.argv) > 2 else 7.0
    rest_time = float(sys.argv[3]) if len(sys.argv) > 3 else 3.0
    
    print("Critical Force Analysis Debug Tool")
    print("=" * 50)
    
    # Load data
    times, forces = load_data(json_file_path)

    print(f"Last force: {forces[-1]}")
    
    # Perform analysis
    results = analyze_critical_force(times, forces, load_time, rest_time)
    
    print("\n" + "=" * 50)
    print("Analysis Complete!")
    
    if results.critical_load > 0:
        print(f"SUCCESS: Critical Force: {results.critical_load:.2f} kg")
    else:
        print("ERROR: Analysis failed - no valid result obtained")
        print("\nPossible issues:")
        print("• Not enough data points above threshold")
        print("• Data doesn't contain clear hang intervals") 
        print("• Threshold too high for the data")
        print("• Data format issues")
    
    # Create plots
    try:
        create_plots(times, forces, results)
        create_detailed_analysis_plot(times, forces, results)
    except Exception as e:
        print(f"WARNING: Could not create plots: {e}")
        print("Note: Install matplotlib with: pip install matplotlib")


if __name__ == "__main__":
    main()
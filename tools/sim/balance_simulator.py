#!/usr/bin/env python3
"""
Headless balance simulator for Embers of the Earth
Runs game simulations to test economy and encounter balance
"""

import json
import random
import csv
from pathlib import Path
from typing import Dict, List, Tuple

class BalanceSimulator:
    """Simulates game runs to test balance"""
    
    def __init__(self, config_path: str = "data/sim_config.json"):
        self.config = self._load_config(config_path)
        self.results = []
        
    def _load_config(self, config_path: str) -> Dict:
        """Load simulation configuration"""
        if Path(config_path).exists():
            with open(config_path) as f:
                return json.load(f)
        return self._default_config()
    
    def _default_config(self) -> Dict:
        """Default simulation configuration"""
        return {
            "runs": 1000,
            "max_days": 500,
            "crop_choices": ["Ironwheat", "Steamroot", "Cogbean"],
            "encounter_rate": 0.3,
            "hazard_rate": 0.2,
            "starting_resources": {
                "food": 10,
                "fuel": 5,
                "coins": 50
            }
        }
    
    def run_simulation(self) -> Dict:
        """Run a single game simulation"""
        # Simplified simulation (would integrate with actual game logic)
        state = {
            "day": 1,
            "dead": False,
            "marriage_days": None,
            "entropy_order": 0.0,
            "entropy_wild": 0.0,
            "bankrupt": False,
            "resources": self.config["starting_resources"].copy()
        }
        
        for day in range(1, self.config["max_days"] + 1):
            state["day"] = day
            
            # Random events
            if random.random() < self.config["encounter_rate"]:
                self._handle_encounter(state)
            
            if random.random() < self.config["hazard_rate"]:
                self._handle_hazard(state)
            
            # Crop harvests (simplified)
            if day % 10 == 0:
                state["resources"]["coins"] += random.randint(5, 15)
            
            # Entropy drift
            state["entropy_order"] += random.uniform(0.1, 0.5)
            state["entropy_wild"] += random.uniform(0.1, 0.5)
            
            # Death check (simplified)
            if state["day"] > 200 and random.random() < 0.01:
                state["dead"] = True
                break
            
            # Marriage (first time)
            if state["marriage_days"] is None and day > 50 and state["resources"]["coins"] > 100:
                if random.random() < 0.05:
                    state["marriage_days"] = day
            
            # Bankruptcy check
            if state["resources"]["coins"] < 0:
                state["bankrupt"] = True
                break
        
        return state
    
    def _handle_encounter(self, state: Dict):
        """Handle random encounter"""
        # Simplified: sometimes lose items
        if random.random() < 0.3:
            state["resources"]["coins"] -= random.randint(1, 10)
    
    def _handle_hazard(self, state: Dict):
        """Handle travel hazard"""
        # Simplified: costs resources
        if random.random() < 0.5:
            state["resources"]["food"] -= 1
        if state["resources"]["food"] < 0:
            state["bankrupt"] = True
    
    def run_batch(self, num_runs: int = None) -> List[Dict]:
        """Run multiple simulations"""
        if num_runs is None:
            num_runs = self.config["runs"]
        
        results = []
        for i in range(num_runs):
            result = self.run_simulation()
            results.append(result)
            if (i + 1) % 100 == 0:
                print(f"Completed {i + 1}/{num_runs} simulations...")
        
        self.results = results
        return results
    
    def generate_report(self, output_path: str = "reports/balance_report.csv"):
        """Generate CSV report from simulation results"""
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w', newline='') as f:
            writer = csv.writer(f)
            
            # Header
            writer.writerow([
                "Run", "Days", "Dead", "Marriage_Day", "Bankrupt",
                "Final_Order", "Final_Wild", "Final_Coins"
            ])
            
            # Data
            for i, result in enumerate(self.results):
                writer.writerow([
                    i + 1,
                    result["day"],
                    result["dead"],
                    result["marriage_days"] or "",
                    result["bankrupt"],
                    round(result["entropy_order"], 2),
                    round(result["entropy_wild"], 2),
                    result["resources"]["coins"]
                ])
        
        # Summary statistics
        self._print_summary()
    
    def _print_summary(self):
        """Print summary statistics"""
        if not self.results:
            return
        
        total = len(self.results)
        avg_days = sum(r["day"] for r in self.results) / total
        survival_rate = sum(1 for r in self.results if not r["dead"]) / total
        avg_marriage_days = sum(
            r["marriage_days"] for r in self.results if r["marriage_days"]
        ) / max(1, sum(1 for r in self.results if r["marriage_days"]))
        bankruptcy_rate = sum(1 for r in self.results if r["bankrupt"]) / total
        avg_entropy_order = sum(r["entropy_order"] for r in self.results) / total
        avg_entropy_wild = sum(r["entropy_wild"] for r in self.results) / total
        
        print("\n=== SIMULATION SUMMARY ===")
        print(f"Total Runs: {total}")
        print(f"Average Days: {avg_days:.1f}")
        print(f"Survival Rate: {survival_rate:.1%}")
        print(f"Average Days to First Marriage: {avg_marriage_days:.1f}")
        print(f"Bankruptcy Rate: {bankruptcy_rate:.1%}")
        print(f"Average Order Entropy: {avg_entropy_order:.1f}")
        print(f"Average Wild Entropy: {avg_entropy_wild:.1f}")
        
        # Flag outliers
        if bankruptcy_rate > 0.3:
            print("⚠️  WARNING: Bankruptcy rate > 30%")
        if survival_rate < 0.5:
            print("⚠️  WARNING: Survival rate < 50%")
        if avg_marriage_days > 200:
            print("⚠️  WARNING: Average marriage day > 200")

def main():
    """Main function"""
    simulator = BalanceSimulator()
    
    print("Running balance simulations...")
    results = simulator.run_batch(1000)
    
    print("\nGenerating report...")
    simulator.generate_report("reports/balance_report.csv")
    
    print("\nDone!")

if __name__ == "__main__":
    main()


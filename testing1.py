"""
import os
hpa_list=os.system("kubectl get hpa --all-namespaces")
print("hpa_list")
print("Hi")
"""
import subprocess

# Get the list of HPAs for all namespaces
hpas=subprocess.run(["kubectl", "get", "hpa", "--all-namespaces"])

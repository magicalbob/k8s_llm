# Description

    Experiment with local hosting LLMs in k8s.

## Choose an Open-Source LLM

For a trial, choose a lightweight, open-source model to minimize resource requirements. Some options:

- LLaMA (Meta) - Requires special access for larger versions.
- GPT-J or GPT-Neo (EleutherAI) - Open models with decent performance.
- Bloom or Bloomz (BigScience) - Scalable transformer models.
- Falcon (TII) - High-quality open-access models.

## Prepare Your Kubernetes Cluster

Ensure your cluster meets basic requirements:

- Node Resources: At least one node with 16+ GB RAM and a decent CPU or GPU.
- Persistent Storage: To store model weights (if needed).
- Networking: Ensure pods can communicate with each other and external endpoints.

## Install Required Tools

You'll need:

- kubectl: CLI tool for Kubernetes. (already done courtesy of https://github.com/magicalbob/vagrant_kubernetes)
- Helm: To manage and deploy charts. (already done courtesy of https://github.com/magicalbob/vagrant_kubernetes)
- Container Registry: Optional, to store custom images. (provided by docker.ellisbs.co.uk ports 5190/7070)
- Node with GPU Support: For larger models, use GPU-enabled nodes. Install NVIDIA drivers and the Kubernetes Device Plugin if applicable.

## Select or Create a Deployment Method
### Use Prebuilt Helm Charts
Run Text Generation WebUI on K8s: A popular tool like Oobabooga's Text Generation WebUI often has community-contributed Helm charts. Look for such resources or adapt a similar deployment.

Run Hugging Face Transformers Inference: Hugging Face provides containerized models. Use their transformers library's text-generation service as an example:

Pull an appropriate Docker image: huggingface/transformers-pytorch-gpu or cpu variants.

## Example Deployment for GPT-Neo
Here’s how you can deploy GPT-Neo with minimal setup:

Prepare Deployment Files
    deployment.yaml:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gpt-neo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gpt-neo
  template:
    metadata:
      labels:
        app: gpt-neo
    spec:
      containers:
      - name: gpt-neo
        image: huggingface/transformers-pytorch-cpu:latest
        ports:
        - containerPort: 8000
        command: ["python"]
        args: ["-m", "transformers.huggingface", "serve", "--model", "EleutherAI/gpt-n
```

    service.yaml:

```
apiVersion: v1
kind: Service
metadata:
  name: gpt-neo-service
spec:
  selector:
    app: gpt-neo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8000
  type: LoadBalancer
```

### Deploy to Kubernetes

    kubectl apply -f deployment.yaml
    kubectl apply -f service.yaml

## Test the Deployment

After deployment:

### Retrieve the external IP of the service:

    kubectl get svc gpt-neo-service

### Test the endpoint using curl or a web browser:

	curl http://<EXTERNAL-IP>:80/generate \
	    -X POST -H "Content-Type: application/json" \
	    -d '{"inputs": "Hello, world!"}'

## Scale and Optimize

For trial use, you can:

    Monitor Resource Usage: Use kubectl top and metrics-server.
    Autoscaling: Experiment with HPA (Horizontal Pod Autoscaler).
    GPU Acceleration: Deploy on GPU nodes for faster inference.

## Clean Up

When finished, clean up your resources:

    kubectl delete -f deployment.yaml
    kubectl delete -f service.yaml

# Description

    Experiment with local hosting LLMs in k8s.

## Choose an Open-Source LLM

For a trial, choose a lightweight, open-source model to minimize resource requirements. Some options:

- LLaMA (Meta) - Requires special access for larger versions.
- GPT-J or GPT-Neo (EleutherAI) - Open models with decent performance.
- Bloom or Bloomz (BigScience) - Scalable transformer models.
- Falcon (TII) - High-quality open-access models.

### Recommendation: GPT-J or GPT-Neo (EleutherAI)

Why it's ideal for you:

    Open and Easily Accessible: No special permissions required, and pre-trained models are available on Hugging Face.
    Lightweight Options: Models like GPT-Neo-1.3B or GPT-J-6B are relatively smaller and require fewer resources compared to BLOOM or LLaMA.
    Docker Support: Official or community Docker images are readily available, making it easy to deploy.
    Community and Examples: EleutherAI models are well-documented with active community support.

Resource Requirement:

    GPT-Neo-1.3B: Can run on a CPU with 16 GB RAM but will be slower.
    GPT-J-6B: Better on GPU, but still manageable for trial use.

## Prepare Your Kubernetes Cluster

Ensure your cluster meets basic requirements:

- Node Resources: At least one node with 16+ GB RAM and a decent CPU or GPU.

All 7 nodes in cluster have:

	free -h
	               total        used        free      shared  buff/cache   available
	Mem:            31Gi       1.1Gi        23Gi       2.0Mi       6.9Gi        29Gi
	Swap:             0B          0B          0B

	and 8 cores all like this:
	vendor_id	: GenuineIntel
	cpu family	: 6
	model		: 62
	model name	: Intel(R) Xeon(R) CPU E5-2697 v2 @ 2.70GHz
	stepping	: 4
	microcode	: 0x19
	cpu MHz		: 2628.724
	cache size	: 30720 KB
	physical id	: 0
	siblings	: 8
	core id		: 7
	cpu cores	: 8
	apicid		: 7
	initial apicid	: 7
	fpu		: yes
	fpu_exception	: yes
	cpuid level	: 13
	wp		: yes
	flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 x2apic popcnt aes xsave avx rdrand hypervisor lahf_lm pti fsgsbase md_clear flush_l1d
	bugs		: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds swapgs itlb_multihit mmio_unknown
	bogomips	: 5257.44
	clflush size	: 64
	cache_alignment	: 64
	address sizes	: 46 bits physical, 48 bits virtual
	power management:

- Persistent Storage: To store model weights (if needed).
- Networking: Ensure pods can communicate with each other and external endpoints.

Current cluster setup with 31 GB RAM per node and 8 CPU cores is well-suited for running small to mid-sized LLMs for learning purposes. Models like GPT-Neo 1.3B or DistilGPT-2 are appropriate choices, and you can comfortably run inference workloads within this environment.

## Install Required Tools

You'll need:

- kubectl: CLI tool for Kubernetes. (already done courtesy of https://github.com/magicalbob/vagrant_kubernetes)
- Helm: To manage and deploy charts. (already done courtesy of https://github.com/magicalbob/vagrant_kubernetes)
- Container Registry: Optional, to store custom images. (provided by docker.ellisbs.co.uk ports 5190/7070)
- Node with GPU Support: For larger models, use GPU-enabled nodes. Install NVIDIA drivers and the Kubernetes Device Plugin if applicable.

Current k8s cluster does not have GPU support, restricts which models can be used:
- GPT-Neo 1.3B (EleutherAI): Small, open, and manageable on CPUs.
- DistilGPT-2 (Hugging Face): A distilled version of GPT-2, optimized for smaller resource usage.
These models provide a good starting point to explore LLM infrastructure and workflows.

## Select or Create a Deployment Method
### Use Prebuilt Helm Charts
Run Text Generation WebUI on K8s: A popular tool like Oobabooga's Text Generation WebUI often has community-contributed Helm charts. Look for such resources or adapt a similar deployment.

Run Hugging Face Transformers Inference: Hugging Face provides containerized models. Use their transformers library's text-generation service as an example:

Pull an appropriate Docker image: huggingface/transformers-pytorch-gpu or cpu variants.

## Example Deployment for GPT-Neo
Here’s how you can deploy GPT-Neo with minimal setup:

Prepare Deployment Files

[deployment.yml](./deployment.yml)

[service.yml](./service.yml)

Set token:
```
kubectl create secret generic huggingface-token -n gpt-neo --from-literal=token=${HUGGING_FACES_TOKEN}
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

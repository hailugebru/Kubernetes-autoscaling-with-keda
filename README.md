# aks-keda
This is reposotory contains scripts used in the blog post of using mssql as KEDA trigger in Azure Kubernetes Service.

The purpose of this blog post is to guide you through the process of setting up an autoscaled application on Azure Kubernetes Service (AKS) using Kubernetes-based Event-Driven Autoscaling (KEDA) triggered by Microsoft SQL Server (MSSQL) queries. By the end of the blog post, you will learn how to:

Set up an AKS cluster
Install KEDA on AKS
Deploy a SQL Server container cluster on AKS
Dockerize a .NET application and deploy it on AKS
Configure KEDA to autoscale your .NET application based on MSSQL queries
This guide will provide you with practical, step-by-step instructions and code examples, allowing you to gain hands-on experience with AKS, KEDA, and MSSQL. By implementing this autoscaled application, you will be able to efficiently manage your resources and ensure your application can handle varying loads, thereby improving the performance and responsiveness of your application.

Before diving into this tutorial, there are a few prerequisites you should have:

Azure Account: You will need an active Azure account. If you don't have one, you can create a free account on the Azure website.
Knowledge of Azure Services: Familiarity with Azure and its services, specifically Azure Kubernetes Service (AKS), is essential.
Familiarity with Kubernetes: Basic understanding of Kubernetes concepts such as Deployments, Services, and Persistent Volumes is necessary.
Understanding of KEDA: Knowledge of Kubernetes-based Event-Driven Autoscaling (KEDA) concepts and how it works will be crucial for this tutorial.
Basic SQL Server Knowledge: Since we will be using MSSQL as a KEDA trigger, a basic understanding of SQL server and SQL queries is required.
Knowledge of .NET: As we will be deploying a .NET application, familiarity with .NET and C# language will be helpful.

Docker Basics: Understanding of Docker and how to create Docker images is necessary since we will be dockerizing the .NET application.

Installed Tools: You should have the following tools installed on your local machine: Azure CLI, Docker, kubectl and Helm.

Having all these prerequisites will ensure a smooth and productive learning experience as you work through this guide.

To deploy a SQL Server container cluster on Azure Kubernetes Service (AKS), you can refer to the official Microsoft Quickstart guide on running SQL Server containers on Azure. This comprehensive guide covers the steps on how to pull the SQL Server 2019 Linux container image from Microsoft Container Registry, deploy the SQL Server container to AKS, and verify the deployment.

---

You can dynamically create an Azure Disk using a Kubernetes StorageClass and a Persistent Volume Claim (PVC). This approach automatically creates an Azure Disk when you create a PVC.

Here's how you can do this:

Create a StorageClass for Azure Disk: First, you need to create a StorageClass for Azure Disk. Here's a sample YAML file for this:

kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: azure-disk
provisioner: kubernetes.io/azure-disk
parameters:
  storageaccounttype: Standard_LRS
  kind: Managed
You can apply this YAML file with the kubectl apply command.

Create a Persistent Volume Claim (PVC): Next, you can create a PVC that uses the StorageClass. Kubernetes will dynamically create an Azure Disk for the PVC. Here's a sample YAML file for the PVC:

kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: azure-disk-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: azure-disk
  resources:
    requests:
      storage: 100Gi
Replace 100Gi with the size of the disk you want.

Use the PVC in your Deployment: Finally, you can use the PVC in your Deployment. In your Deployment YAML file, specify the PVC as a volume and mount it at the appropriate path.

Remember to replace all placeholders with your actual values. Always refer to the official Kubernetes and Azure documentation for the most accurate and detailed instructions.

---

To connect to the SQL Server running on AKS from your local machine using SQL Server Management Studio (SSMS), you can follow these steps:

Get the External IP of the Service: First, you need to get the external IP of the Service that exposes your SQL Server Deployment. You can use the following kubectl command:

kubectl get service <service-name>
Replace <service-name> with the name of your Service. The external IP is listed under the EXTERNAL-IP column.

Connect to SQL Server using SSMS: Start SSMS on your local machine and use the external IP to connect to SQL Server. The server name should be the external IP of the Service, the authentication should be SQL Server Authentication, and you should use the SQL Server username and password that you specified when deploying SQL Server.

Please note that this method exposes your SQL Server to the internet, which might not be secure. Always ensure your SQL Server is protected by a firewall and use secure connections.


---
This YAML file contains the configuration for the Kubernetes Event-Driven Autoscaling (KEDA), a project that provides event driven scaling for Kubernetes.

Here's a breakdown of the sections in this YAML file:

Secret: This section defines a Kubernetes secret named mssql-secrets. Secrets are used to store sensitive data, like a password or a token. In this case, the secret is storing a connection string for MSSQL server. It uses the key mssql-connection-string for this secret data. The actual connection string value should replace "Replace the connection string here".

TriggerAuthentication: This section defines a KEDA TriggerAuthentication resource named keda-trigger-auth-mssql-secret. It references the secret mssql-secrets that was defined in the previous section.

ScaledObject: This is the main part of the KEDA configuration. It defines a ScaledObject resource that configures how the application should scale:

scaleTargetRef points to the resource that will be scaled. In this case, it's a Kubernetes deployment named webapp-deployment.

pollingInterval is the frequency (in seconds) at which KEDA checks for new events. The default value is 30 seconds, but here it's set to 1 second.

cooldownPeriod is the period (in seconds) to wait after the last event before scaling down. The default value is 300 seconds, but here it's set to 30 seconds.

minReplicaCount and maxReplicaCount set the minimum and maximum number of replicas that KEDA will scale to.

triggers defines the triggers that cause the scaling. In this case, there's one trigger of type mssql. This trigger will cause the application to scale based on the result of a SQL query. The targetValue is the threshold that triggers the scaling. The query is the SQL query that is run to determine whether to scale. The authenticationRef points to the TriggerAuthentication resource that provides the authentication information for the trigger.

In summary, this configuration is set up to scale a Kubernetes deployment named webapp-deployment based on the number of new messages in an MSSQL database. The connection to the database is secured using a secret. The deployment will scale up when there are more than 5 new messages and scale down when there are fewer. The scaling parameters are tuned for a fast response with a high maximum replica count.

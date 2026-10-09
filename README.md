**# AWS Infrastructure Automation with Terraform**



**\*\*Candidate Name:\*\* Ravi Shankar Tripathi**  

**\*\*Project Directory:\*\* `Terraform\_Ravi\_Shankar\_Tripathi`**  

**\*\*Cloud Platform:\*\* AWS (Region: ap-south-1)**  

**\*\*Tools \& Tech:\*\* Terraform, AWS CLI, Docker, Amazon ECR, Amazon ECS (Fargate), Application Load Balancer, EC2, VPC**



**---**



**## 📌 Executive Summary**



**This project implements end-to-end Infrastructure as Code (IaC) solutions deploying a two-tier application (Express Frontend \& Flask Backend) across three progressive architectural paradigms on AWS:**

**1. \*\*Single EC2 Architecture:\*\* Co-located web \& API services provisioned with automated bootstrapping.**

**2. \*\*Two-Tier Separate EC2 Architecture:\*\* Dedicated backend and frontend instances inside a custom VPC with cross-instance internal networking.**

**3. \*\*Enterprise Containerized Deployment:\*\* High-availability serverless containers using Amazon ECR, Amazon ECS (Fargate), and Application Load Balancer (ALB).**



**---**



**## 📂 Repository Directory Layout**



**```text**

**Terraform\_Ravi\_Shankar\_Tripathi/**

**├── app/**

**│   ├── backend/**

**│   │   ├── Dockerfile**

**│   │   ├── app.py**

**│   │   └── requirements.txt**

**│   └── frontend/**

**│       ├── Dockerfile**

**│       ├── server.js**

**│       └── package.json**

**├── part1-single-ec2/**

**│   ├── main.tf**

**│   ├── variables.tf**

**│   └── outputs.tf**

**├── part2-multi-ec2/**

**│   ├── main.tf**

**│   ├── variables.tf**

**│   └── outputs.tf**

**├── part3-ecs-fargate/**

**│   ├── main.tf**

**│   ├── variables.tf**

**│   └── outputs.tf**

**├── screenshots/**

**│   ├── part1-init-plan.png**

**│   ├── part1-apply-output.png**

**│   ├── part1-browser-verification.png**

**│   ├── part2-apply-output.png**

**│   ├── part2-backend-json.png**

**│   ├── part3-ecr-repositories.png**

**│   ├── part3-apply-output.png**

**│   ├── part3-frontend-form.png**

**│   └── part3-backend-json.png**

**├── .gitignore**

**└── README.md**


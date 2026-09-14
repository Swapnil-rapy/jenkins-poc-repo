pipeline {
    agent {
        kubernetes {
            inheritFrom 'k8s-agent'
        }
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/Swapnil-rapy/jenkins-poc-repo.git',
                    branch: 'main'
            }
        }

        stage('Environment') {
            steps {
                sh '''
                    echo "===== Environment ====="
                    python3 --version
                    pip3 --version
                    git --version
                    java -version
                    kubectl version --client
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    . .venv/bin/activate
                    PYTHONPATH=. pytest -v
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    set -e

                    echo "===== Deploying to EKS ====="

                    cat <<'EOF' > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: poc-app
  namespace: poc-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: poc-app
  template:
    metadata:
      labels:
        app: poc-app
    spec:
      containers:
        - name: nginx
          image: nginx:1.27
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: poc-app
  namespace: poc-app
spec:
  type: ClusterIP
  selector:
    app: poc-app
  ports:
    - port: 80
      targetPort: 80
EOF

                    echo "===== Kubernetes Manifest ====="
                    cat deployment.yaml

                    echo "===== Applying Kubernetes Manifest ====="
                    kubectl apply -f deployment.yaml

                    echo "===== Waiting for Rollout ====="
                    kubectl rollout status deployment/poc-app \
                      -n poc-app \
                      --timeout=180s
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    set -e

                    echo "===== Deployment Status ====="

                    kubectl get deployment poc-app -n poc-app

                    echo "===== Pods ====="

                    kubectl get pods -n poc-app -l app=poc-app

                    echo "===== Service ====="

                    kubectl get service poc-app -n poc-app

                    echo "===== Deployment Verification ====="

                    kubectl wait \
                      --for=condition=available \
                      deployment/poc-app \
                      -n poc-app \
                      --timeout=180s

                    echo "Deployment verification successful"
                '''
            }
        }
    }

    post {
        always {
            echo 'CI/CD pipeline completed'
        }

        success {
            echo 'CI/CD pipeline completed successfully'
        }

        failure {
            echo 'CI/CD pipeline failed'
        }
    }
}



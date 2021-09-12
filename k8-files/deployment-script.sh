kubectl apply -f ./deployment-api-feed.yaml
kubectl apply -f ./deployment-api-user.yaml
kubectl apply -f ./deployment-frontend.yaml
kubectl apply -f ./deployment-reverseproxy.yaml
kubectl apply -f ./service-api-feed.yaml
kubectl apply -f ./service-api-user.yaml
kubectl apply -f ./service-frontend.yaml
kubectl apply -f ./service-reverseproxy.yaml

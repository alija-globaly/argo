# argo

kubectl port-forward \
  --address 0.0.0.0 \
  svc/argocd-server -n argocd 8080:443

argocd admin initial-password -n argocd 
jFsnF1h-sBStCu0N
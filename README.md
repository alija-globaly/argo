# argo

kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443


argocd admin initial-password -n argocd 
sEIDB4LKd7Nm-owH

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
sEIDB4LKd7Nm-owH
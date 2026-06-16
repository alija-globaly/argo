# argo

kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443

kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8090:443


argocd admin initial-password -n argocd
KYEChxiqJhLNY0DZ


stagingserver - argocd admin initial-password -n argocd
DmOogOprb8YGnyKD

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo


kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
sEIDB4LKd7Nm-owH




mumbai region
ubuntu@root-master-nginx-ingress-172-34-0-67:~$ kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
gwMRVh-6-L7831lp


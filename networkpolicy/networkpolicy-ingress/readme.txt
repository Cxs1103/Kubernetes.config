

# kubectl apply -f pod-demo.yaml

# kubectl -n my-nginx get  pod -o wide
NAME                        READY   STATUS    RESTARTS   AGE     IP           NODE    NOMINATED NODE   READINESS GATES
my-nginx-5b45645cbc-lqh9w   1/1     Running   0          6m23s   10.0.2.42    node2   <none>           <none>
my-nginx-5b45645cbc-t586w   1/1     Running   0          6m23s   10.0.2.234   node2   <none>           <none>
my-nginx-5b45645cbc-txrt5   1/1     Running   0          6m23s   10.0.1.205   node1   <none>           <none>

# kubectl exec -ti pod-test -- /bin/sh
/ #
/ # ping 10.0.2.42
PING 10.0.2.42 (10.0.2.42): 56 data bytes
64 bytes from 10.0.2.42: seq=0 ttl=63 time=1.435 ms
64 bytes from 10.0.2.42: seq=1 ttl=63 time=0.493 ms
64 bytes from 10.0.2.42: seq=2 ttl=63 time=0.504 ms
64 bytes from 10.0.2.42: seq=3 ttl=63 time=1.525 ms
64 bytes from 10.0.2.42: seq=4 ttl=63 time=0.517 ms
64 bytes from 10.0.2.42: seq=5 ttl=63 time=0.561 ms
64 bytes from 10.0.2.42: seq=6 ttl=63 time=0.632 ms
64 bytes from 10.0.2.42: seq=7 ttl=63 time=0.645 ms


# kubectl apply -f networkpolicy-demo.yaml
networkpolicy.networking.k8s.io/default-deny-ingress created


# kubectl exec -ti pod-test -- /bin/sh
/ #
/ # ping 10.0.2.42  # 再ping，发现不通了
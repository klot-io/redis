docker_build('redis-klot-io', '.')

k8s_yaml(kustomize('.'))

k8s_resource('db', port_forwards=['6379:6379'])
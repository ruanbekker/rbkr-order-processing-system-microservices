# ----------
# Functions
# ----------
def load_yaml_tree(path):
    return [f for f in listdir(path, recursive=True) if f.endswith('.yaml')]

#def load_yaml_tree(path):
#    files = []
#    for f in listdir(path, recursive=True):
#        if f.endswith('.yaml'):
#            files.append(f)
#    return files

# -----------------------------
# Kubernetes manifests
# Bootstrap (jobs)
# -----------------------------
#print(load_yaml_tree('infra/kubernetes/bootstrap'))
#k8s_yaml(load_yaml_tree('infra/kubernetes/bootstrap/**/*.yaml'))
k8s_yaml(load_yaml_tree('infra/kubernetes/bootstrap'))

# -----------------------------
# Dependencies (infra)
# -----------------------------
# k8s_yaml(str(local('find infra/kubernetes/dependencies -name "*.yaml" -print')).split('\n'))
k8s_yaml(load_yaml_tree('infra/kubernetes/dependencies'))

# -----------------------------
# Services
# -----------------------------
# k8s_yaml(str(local('find infra/kubernetes/services -name "*.yaml" -print')).split('\n'))
k8s_yaml(load_yaml_tree('infra/kubernetes/services'))

# -----------------------------
# Order Service
# -----------------------------
docker_build(
    'ttl.sh/rbkr-ops-order-service-dev:2h',
    '../rbkr-ops-order-service',
	live_update=[
	    sync('../rbkr-ops-order-service', '/app'),
		# run('go build -o app ./cmd/api', trigger=['**/*.go']),
	],
)

k8s_resource('order-service', resource_deps=['postgres', 'kafka'], labels=['services'], port_forwards=8080)

# -----------------------------
# Inventory Service
# -----------------------------
docker_build(
    'ttl.sh/rbkr-ops-inventory-service-dev:2h',
    '../rbkr-ops-inventory-service',
)

k8s_resource('inventory-service', resource_deps=['redis', 'kafka'], labels=['services'])

# -----------------------------
# Notification Service
# -----------------------------
docker_build(
    'ttl.sh/rbkr-ops-notification-service-dev:2h',
    '../rbkr-ops-notification-service',
)

k8s_resource('notification-service', resource_deps=['kafka'], labels=['services'])

# -----------------------------
# Infra (no builds)
# -----------------------------
k8s_resource('kafka', labels=['infra'])
k8s_resource('redis', labels=['infra'])
k8s_resource('postgres', labels=['infra'])

# -----------------------------
# Jobs
# -----------------------------
k8s_resource('kafka-topics', labels=['bootstrap'], trigger_mode=TRIGGER_MODE_MANUAL)
k8s_resource('redis-seed', labels=['bootstrap'], trigger_mode=TRIGGER_MODE_MANUAL)
k8s_resource('db-migrate', labels=['bootstrap'], trigger_mode=TRIGGER_MODE_MANUAL)

# --------------------
# Manual Bootstraps
# --------------------
# local('kubectl apply -f infra/kubernetes/dependencies/', trigger_mode=TRIGGER_MODE_MANUAL)

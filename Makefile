# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash

HELM := helm
TASK := build

EXCLUDES := helm-toolkit doc tests tools logs tmp influxdb kafka \
	keystone-init monasca-agent monasca-alarms monasca mysql-users-init storm \
	zookeeper zuul.d releasenotes
CHARTS := helm-toolkit $(filter-out $(EXCLUDES), $(patsubst %/.,%,$(wildcard */.)))

.PHONY: $(EXCLUDES) $(CHARTS)

all: $(CHARTS)

$(CHARTS):
	@echo
	@echo "===== Processing [$@] chart ====="
	@make $(TASK)-$@

init-%:
	if [ -f $*/Makefile ]; then make -C $*; fi
	if [ -f $*/requirements.yaml ]; then helm dep up $*; fi

lint-%: init-%
	if [ -d $* ]; then $(HELM) lint $*; fi

build-%: lint-%
	if [ -d $* ]; then $(HELM) package $*; fi

# This is used exclusively with helm3 building in the gate to publish
package-%: init-%
	if [ -d $* ]; then $(HELM) package $*; fi

clean:
	@echo "Removed .b64, _partials.tpl, and _globals.tpl files"
	rm -f helm-toolkit/secrets/*.b64
	rm -f */templates/_partials.tpl
	rm -f */templates/_globals.tpl
	rm -f *tgz */charts/*tgz
	rm -f */requirements.lock
	-rm -rf */charts */tmpcharts

pull-all-images:
	@./tools/pull-images.sh

pull-images:
	@./tools/pull-images.sh $(filter-out $@,$(MAKECMDGOALS))

dev-deploy:
	@./tools/gate/devel/start.sh $(filter-out $@,$(MAKECMDGOALS))

%:
	@:

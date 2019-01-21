Terraform Kubectl Helm
----------------------

Simple AIO image for CI.

Available as `egeneralov/tkh`.

Sample .gitlab-ci.yml
---------------------

    stages:
      - build
      - publish
      - deploy
    
    build:
      image: docker:dind
      stage: build
      script:
        - docker build --pull -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG-$CI_COMMIT_SHA" .
        - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
        - docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG-$CI_COMMIT_SHA"
    
    
    .deploy: &deploy
      script:
        - export RELEASE_NAME="$CI_ENVIRONMENT_SLUG-$CI_PROJECT_NAME"
        - export URL="$CI_ENVIRONMENT_SLUG.$CI_PROJECT_NAME.domain.tld"
        - export HELM_SETS="--set image.repository=$CI_REGISTRY_IMAGE --set image.tag=$CI_COMMIT_REF_SLUG-$CI_COMMIT_SHA --set ingress.hosts[0]=$URL"
        - export HELM_OPTS="${RELEASE_NAME} .helm --namespace $KUBE_NAMESPACE ${HELM_SETS} --wait"
        - export
        - (helm install --name ${HELM_OPTS} || helm upgrade ${HELM_OPTS} ) || ( helm history --max 2 ${RELEASE_NAME} | head -n 2 | tail -n 1 | awk '{print $1}' | xargs helm rollback ${RELEASE_NAME} )
      image: docker.io/egeneralov/tkh
      stage: deploy
      tags:
        - kubernetes
    
    
    stage:
      environment:
        name: stage-myproject
        url: https://$CI_ENVIRONMENT_SLUG.$CI_PROJECT_NAME.domain.tld/
      <<: *deploy
      only:
        - stage

    
    prod:
      environment:
        name: prod-myproject
        url: https://$CI_ENVIRONMENT_SLUG.$CI_PROJECT_NAME.domain.tld/
      <<: *deploy
      when: manual
      only:
        - master

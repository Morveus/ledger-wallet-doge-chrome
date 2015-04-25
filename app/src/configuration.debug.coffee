@ledger.env = "dev"
@ledger.isProd = ledger.env == "prod"
@ledger.isDev = ledger.env == "dev"

@ledger.config ?= {}
_.extend @ledger.config,
  m2fa:
    baseUrl: 'ws://doge.morveus.com/2fa/channels'
  restClient:
    baseUrl: 'http://doge.morveus.com/'
  syncRestClient:
    pullIntervalDelay: 60000
    pullThrottleDelay: 1000
    pushDebounceDelay: 1000
  enableLogging: yes

Q.longStackSupport = true

@configureApplication = (app) ->
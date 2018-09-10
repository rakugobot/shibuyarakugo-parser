(defsystem "shibuyarakugo-parser"
  :class :package-inferred-system
  :version "0.1.0"
  :author "Eitaro Fukamachi"
  :license "BSD 2-Clause"
  :description "Parser for an HTML of http://eurolive.jp/shibuya-rakugo/"
  :depends-on ("shibuyarakugo-parser/main")
  :in-order-to ((test-op (test-op "shibuyarakugo-parser/tests"))))
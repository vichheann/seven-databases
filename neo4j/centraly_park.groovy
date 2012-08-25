//load common.groovy

role_count = [:]
count = 0
g.V.in.groupCount(role_count).loop(2){
  count++ < 100
  }.count()
role_count.sort{a,b->b.value<=>a.value}.take(5).collect{k,v->k.name + " = " + v}

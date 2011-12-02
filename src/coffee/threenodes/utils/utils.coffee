ThreeNodes.uid = 0

ThreeNodes.Utils = {}
ThreeNodes.Utils.get_uid = () ->
  ThreeNodes.uid += 1
  
class ThreeNodes.Utils.Rc4Random
  # Rc4Random function taken from http://www.webdeveloper.com/forum/showthread.php?t=140572
  constructor: (seed) ->
    @keySchedule = []
    @keySchedule_i = 0
    @keySchedule_j = 0
    
    for i in [0..256]
      @keySchedule[i] = i
    j = 0
    for i in [0..256]
      j = (j + @keySchedule[i] + seed.charCodeAt(i % seed.length)) % 256
      t = @keySchedule[i]
      @keySchedule[i] = @keySchedule[j]
      @keySchedule[j] = t
  
  getRandomByte: () =>
    @keySchedule_i = (@keySchedule_i + 1) % 256
    @keySchedule_j = (@keySchedule_j + @keySchedule[@keySchedule_i]) % 256
    
    t = @keySchedule[@keySchedule_i]
    @keySchedule[@keySchedule_i] = @keySchedule[keySchedule_j]
    @keySchedule[@keySchedule_j] = t
    return @keySchedule[(@keySchedule[@keySchedule_i] + @keySchedule[@keySchedule_j]) % 256]
  
  getRandomNumber: () =>
    number =  0
    multiplier = 1
    for i in [0..8]
      number += @getRandomByte() * multiplier
      multiplier *= 256
    return number / 18446744073709551616

ThreeNodes.Utils.flatArraysAreEquals = (arr1, arr2) ->
  if arr1.length != arr2.length
    return false
  
  for k, i in arr1
    if arr1[i] != arr2[i]
      return false
      
  true

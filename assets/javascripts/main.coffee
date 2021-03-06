baserApp = angular.module('baserApp', [])
baserApp.controller('BoardCtrl', ['$scope', '$http', ($scope, $http) ->
  $scope.myColor = 'blue'
  $scope.tool = 'type'
  $scope.orderBy = 'Length'
  $scope.words = []
  $scope.board = []
  $scope.board[r] = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}] for r in [0..12]

  $scope.changeTool = ($tool) ->
    _gaq.push(['_trackEvent', 'Board', 'ChangeTool', $tool])
    $scope.tool = $tool

  $scope.changeColor = (row, column) ->
    if $scope.tool isnt 'type'
      $scope.board[row][column].color = $scope.tool

  $scope.getBoard = ->
    _.inject $scope.board, ((memo, el) ->
      memo.push _.map(el, (el) -> el.value)
      memo
    ), []

  $scope.pointClass = (row, column) ->
    classes = []
    if $scope.board[row][column].color
      classes.push $scope.board[row][column].color
    if $scope.board[row][column].selected
      classes.push 'selected'
    classes.join ' '

  $scope.getPoints = ->
    _.inject $scope.board, ((memo, el, row) ->
      _.each el, (el, column) ->
        memo.push [row, column] if el.color is $scope.myColor
      memo
    ), []

  $scope.getWords = ->
    _gaq.push(['_trackEvent', 'Board', 'Generate', 'Generate'])
    responsePromise = $http.post('/board',
      board: $scope.getBoard()
      points: $scope.getPoints())
    responsePromise.success (data, status, headers, config) ->
      $scope.data = data
      $scope.words = data.words
      $scope.orderWords()

  $scope.testData = ->
    _gaq.push(['_trackEvent', 'Board', 'Generate', 'Test Data'])
    for r in [0..12]
      for c in [0..9]
        $scope.board[r][c].value = String.fromCharCode(65 + Math.round(Math.random() * 10000) % 26)

  $scope.orderWords = ->
    _gaq.push(['_trackEvent', 'Board', 'Order', $scope.orderBy])
    $scope.words = $scope['_orderWordsBy' + $scope.orderBy]($scope.words)

  $scope._orderWordsByLength = (words) ->
    _.sortBy(words, (el) ->
      el.word.length
    ).reverse()

  $scope._orderWordsByHighest = (words) ->
    _.sortBy words, (el) ->
      _.inject el.chart, ((memo, point) ->
        Math.min memo, point[0]
      ), 12

  $scope._orderWordsByLowest = (words) ->
    _.sortBy(words, (el) ->
      _.inject el.chart, ((memo, point) ->
        Math.max memo, point[0]
      ), 0
    ).reverse()

  $scope.highlightWord = (word, points) ->
    _gaq.push(['_trackEvent', 'Board', 'Highlight', word])
    for r in [0..12]
      for c in [0..9]
        $scope.board[r][c].selected = false
    for id,point of points
      $scope.board[point[0]][point[1]].selected = true
])

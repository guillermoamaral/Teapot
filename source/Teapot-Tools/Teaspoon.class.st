"
I provide a graphical interface for quickly testing and excesising routes. Right click on a route in the inspector to open me.
"
Class {
	#name : #Teaspoon,
	#superclass : #ComposableModel,
	#instVars : [
		'urlInput',
		'contentTypeDropList',
		'contentTypeLabel',
		'methodDropList',
		'execButton',
		'requestBody',
		'consumer'
	],
	#category : #'Teapot-Tools-UI'
}

{ #category : #specs }
Teaspoon class >> defaultSpec [
	^ SpecLayout composed
		newColumn: [ :col | 									
			col 
				newRow: [ :row | 
					row 
						add: #methodDropList width: 90;
						add: #urlInput ]
				height: self inputTextHeight.
			col
				add: #requestBody;
				add: #contentTypeLabel height: self inputTextHeight;
				add: #contentTypeDropList height: self inputTextHeight.
			col 
				newRow: 
					[ :row | row add: #execButton ] 
				height: self buttonHeight				
		]
]

{ #category : #'private - accessing' }
Teaspoon class >> iconProvider [

	^TeaIconProvider 
]

{ #category : #'world menu' }
Teaspoon class >> menuCommandOn: aBuilder [ 
	<worldMenu> 
	
	(aBuilder item: #'Teaspoon')	 
		help: 'Teaspoon'; 
		parent: #'Tools' translated;
		icon: self iconProvider teaspoonIcon;
		action: [ self open ].
]

{ #category : #interface }
Teaspoon class >> open [
	<script>
	
	(self new)
		openWithSpec;
		yourself
]

{ #category : #specs }
Teaspoon class >> title [
	^ 'Teaspoon client'
]

{ #category : #private }
Teaspoon >> client [
	^ ZnClient new
		url: self urlInput text;
		method: self methodDropList selectedItem;
		entity: (ZnStreamingEntity 
			readFrom: (ReadStream on: requestBody urlEncoded)
			usingType: self contentTypeDropList selectedItem
			andLength: requestBody urlEncoded size)
		yourself
]

{ #category : #private }
Teaspoon >> consumer [
	^ consumer ifNil: [ consumer := [ :any | any inspect ] ]
]

{ #category : #accessing }
Teaspoon >> contentTypeDropList [
	^ contentTypeDropList
]

{ #category : #accessing }
Teaspoon >> contentTypeLabel [
	^ contentTypeLabel
]

{ #category : #accessing }
Teaspoon >> execButton [
	^ execButton
]

{ #category : #api }
Teaspoon >> initialExtent [
	^  580@420
]

{ #category : #initialization }
Teaspoon >> initializePresenter [
	execButton
		whenActionPerformedDo: [ 
			self urlInput text notEmpty
				ifTrue: [ self consumer value: self client execute ]]
]

{ #category : #initialization }
Teaspoon >> initializeWidgets [
	methodDropList := self newMethodDropList.
	urlInput := self newTextInput autoAccept: true; yourself.
	requestBody := TeaRequestBodyTabs new.
	contentTypeLabel := self newLabel label: 'Content Type'; yourself.
	contentTypeDropList := self newContentTypeDropList.
	execButton := self newButton label: 'Execute request'; yourself.
]

{ #category : #'tea spoon' }
Teaspoon >> method: methodString url: urlString port: portNumber [
	self populateMethod: methodString.
	self populateUrl: urlString port: portNumber.
]

{ #category : #accessing }
Teaspoon >> methodDropList [
	^ methodDropList
]

{ #category : #initialization }
Teaspoon >> newContentTypeDropList [
	| dropList |
	dropList := self newDropList.
	#(
		applicationFormUrlEncoded 
		applicationJson 
		applicationXml 
		applicationSton 
		applicationOctetStream 
		text 
		textHtml 
		textPlain
	) do: [ :each | dropList addItemLabeled: (each value: ZnMimeType) do: [] ].	
	^ dropList
]

{ #category : #initialization }
Teaspoon >> newMethodDropList [
	| dropList |
	dropList := self newDropList.
	ZnConstants knownHTTPMethods do: [ :each | 
		dropList addItemLabeled: each do: [] ].
	^ dropList
]

{ #category : #'tea spoon' }
Teaspoon >> onHttpResultDo: aBlock [
	consumer := aBlock
]

{ #category : #private }
Teaspoon >> populateMethod: methodString [
	| selected |
	selected := methodDropList listItems
		detect: [ :each | each = methodString ]
		ifNone: [ methodDropList listItems first ].
	methodDropList setSelectedItem: selected
]

{ #category : #private }
Teaspoon >> populateUrl: urlString port: portNumber [
	| pathSegment |
	pathSegment := urlString.
	(pathSegment beginsWith: '/') 
		ifFalse: [ pathSegment := '/', pathSegment ].	
	urlInput text: ('http://localhost:', portNumber asString, pathSegment)
]

{ #category : #accessing }
Teaspoon >> requestBody [
	^ requestBody
]

{ #category : #accessing }
Teaspoon >> urlInput [
	^ urlInput
]

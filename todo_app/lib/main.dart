import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  final String title = 'Todo';

  @override
  createState() {
    return TodoState();
  }
}

class TodoEntity {
  final int id;
  String content;

  TodoEntity(this.id, this.content);
}

class TodoState extends State<MyApp> {
  final _todos = <TodoEntity>[];
  final _todoContentController = TextEditingController();
  int lastId = 0;

  _onPressAddTodo() {
    setState(() {
      final nextId = ++lastId;
      this._todos.add(TodoEntity(nextId, this._todoContentController.text));
      this._todoContentController.clear();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  _onPressDeleteTodo(TodoEntity entity) {
    setState(() {
      this._todos.remove(entity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: widget.title,
        home: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TodoList(
                    todos: this._todos,
                    onPressDeleteTodo: this._onPressDeleteTodo,
                  ),
                  TodoInputField(
                    todoContentController: this._todoContentController,
                    onPressAddTodo: this._onPressAddTodo,
                  ),
                ])));
  }
}

class TodoList extends StatelessWidget {
  final List<TodoEntity> todos;
  final void Function(TodoEntity entity) onPressDeleteTodo;

  TodoList({this.todos, this.onPressDeleteTodo});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: this.todos.length,
            itemBuilder: (contenxt, index) {
              final entity = this.todos[index];
              return TodoListItem(
                entity: entity,
                onPress: () {
                  this.onPressDeleteTodo(entity);
                },
              );
            }));
  }
}

class TodoListItem extends StatelessWidget {
  final TodoEntity entity;
  final VoidCallback onPress;

  TodoListItem({this.entity, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            FocusScope.of(context).requestFocus(FocusNode());
            this.onPress();
          },
        ),
        Expanded(
            child: ListTile(
          title: Text(entity.content),
        )),
      ],
    );
  }
}

class TodoInputField extends StatelessWidget {
  final VoidCallback onPressAddTodo;
  final TextEditingController todoContentController;

  TodoInputField({this.onPressAddTodo, this.todoContentController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  controller: this.todoContentController,
                ))),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: RaisedButton(
              onPressed: this.onPressAddTodo,
              child: Text('追加'),
            )),
      ],
    );
  }
}

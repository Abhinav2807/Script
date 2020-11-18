import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:script/providers/authorization.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AuthState();
  }
}

class AuthState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _passwordController = TextEditingController();
  bool login = true;
  AnimationController _controller;
  Animation<double> _fadeAnimation;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An Error Occured!'),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Text('Okay'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();

    try {
      if (login) {
        await Provider.of<Authenticate>(context, listen: false)
            .signin(_authData['email'], _authData['password']);
        // Log user in
      } else {
        // Sign user up
        await Provider.of<Authenticate>(context, listen: false)
            .signUp(_authData['email'], _authData['password']);
      }
    } catch (error) {
      _showErrorMessage('Invalid Email or Password Combination!');
    }
  }

  void toggle() {
    if (login) {
      setState(() {
        login = false;
      });
      _controller.forward();
    } else {
      setState(() {
        login = true;
      });
      _controller.reverse();
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 500));
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Curves.easeIn,
      parent: _controller,
    ));
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Authenticate>(context, listen: false);
    // TODO: implement build
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 100, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                "Script",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 60),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        )),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Invalid email!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        )),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 5) {
                        return 'Password is too short!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  AnimatedContainer(
                    padding: EdgeInsets.only(bottom: 30),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                        minHeight: login ? 0 : 60, maxHeight: login ? 0 : 120),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: TextFormField(
                        enabled: !login,
                        decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2.0),
                            )),
                        obscureText: true,
                        validator: !login
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                            colors: [Colors.black, Colors.black54],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),
                    height: 56,
                    child: FlatButton(
                      onPressed: _submit,
                      child: Text(
                        login ? 'Login' : 'Sign up',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  FlatButton(
                      onPressed: toggle,
                      child: Text(login ? 'Sign up instead' : 'Login Instead')),
                ],
              ),
            ),
            // Spacer(),
            Center(
                child: Text(
              "Or",
              style: TextStyle(fontSize: 20),
            )),
            Container(
              width:double.infinity ,
              height: 56,
              child: FlatButton.icon(
                onPressed: () async {
                  await auth.google_signin();
                },
                icon: Icon(
                  Icons.email,
                  color: Colors.white,
                ),
                label: Text(
                  'Sign in with Gmail',
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
              ),
            ),

            // Lets skip this for a while
            // FlatButton(
            //     onPressed: () async {
            //       await auth.signInAnonymously();
            //     },
            //     child: Text(
            //       'Sign in Anonymously?',
            //     ))
          ],
        ),
      ),
    );
  }
}

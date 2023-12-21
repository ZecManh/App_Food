import 'package:datn/screen/learner/dash_board_learner.dart';
import 'package:datn/screen/tutor/dash_board_tutor.dart';
import 'package:datn/viewmodel/user_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'choose_type.dart';


class ChooseTypeAfterLogin extends StatefulWidget {
  const ChooseTypeAfterLogin({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChooseTypeAfterLoginState();
  }
}

class _ChooseTypeAfterLoginState extends State<ChooseTypeAfterLogin> {
  Color tutorColor = Colors.white;
  Color learnerColor = Colors.white;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserTypeModel>(
      create: (BuildContext context) {
        return UserTypeModel();
      },
      child: Scaffold(
        body: Consumer<UserTypeModel>(
          builder: (context, UserTypeModel value, child) {
            return Container(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    const Image(
                      image: AssetImage('assets/ic_logo_remove_bg.png'),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Bạn là ai ?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(40),
                                  ),
                                  side: (value.userType == UserType.tutor)
                                      ? BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)
                                      : BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background)),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: TextButton.icon(
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            const EdgeInsets.all(20))),
                                onPressed: () async {
                                  value.changeUserType(UserType.tutor);

                                },
                                icon: Image.asset('assets/ic_teacher.png',
                                    width: 50),
                                label: const Text(
                                  'Người dạy',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(40),
                                ),
                                side: (value.userType == UserType.learner)
                                    ? BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)
                                    : BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background),
                              ),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: TextButton.icon(
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            const EdgeInsets.all(20))),
                                onPressed: () async {
                                  value.changeUserType(UserType.learner);
                                },
                                icon: Image.asset('assets/ic_student.png',
                                    width: 50),
                                label: const Text(
                                  'Người học',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            )
                          ]),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        if(value.userType==UserType.tutor){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashBoardTutor(),
                              ));
                        }else{
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashBoardLearner(),
                              ));
                        }

                      },
                      icon: Icon(Icons.arrow_forward_rounded,
                          color: Theme.of(context).colorScheme.background),
                      label: Text(
                        'Tiếp theo',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.background),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primary)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

//'use strict';
import React, {Component} from 'react';
//import FCM from 'react-native-fcm';

import {
    AppRegistry,
    StyleSheet,
    Text,
    View,
    Button,
    TextInput,
    Modal,
    ScrollView,
    NativeModules
} from 'react-native';

var ApplozicChat = NativeModules.ApplozicChat;

export default class AwesomeProject extends Component {

    constructor(props) {
        super(props);
        this.state = {
            userId: '',
            email: '',
            phoneNumer: '',
            pass_word: '',
            displayName: '',
            loggedIn: false,
            visible: false,
            title: 'Login/SignUp',
            mytoken: ''
        };
        this.isUserLogIn = this.isUserLogIn.bind(this);
        this.chatLogin = this.chatLogin.bind(this);
        this.logoutUser = this.logoutUser.bind(this);
        this.show = this.show.bind(this);
        this.openChat = this.openChat.bind(this);
        this.createGroup = this.createGroup.bind(this);
        this.addMemberToGroup = this.addMemberToGroup.bind(this);
        this.openChatWithUser = this.openChatWithUser.bind(this);

        this.getUnreadCountForUser = this.getUnreadCountForUser.bind(this);
        this.getUnreadCountForChannel = this.getUnreadCountForChannel.bind(this);
        this.totalUnreadCount = this.totalUnreadCount.bind(this);

    }

    componentDidMount() {

        // FCM.getFCMToken().then(token => {
        //     this.setState({mytoken: token});
        //     console.log(token)
        // });
        //
        // this.refreshUnsubscribe = FCM.on('refreshToken', (token) => {
        //     this.refreshToken()
        //
        // });

      //  this.isUserLogIn();

    }

    componentWillUnMount()
    {
        this.refreshUnsubscribe();

    }
    openModal() {
        this.setState({modalVisible:true});
      }

    closeModal() {
        this.setState({modalVisible:false});
    }
    openOneToOneChat(){
     alert("");

    }

    show() {
        this.setState({title: 'Loading....!'});
        this.chatLogin();
    }

    render() {
          let display = this.state.loggedIn;
          if (display) {
            return (
			  <View style = {styles.container}>
        <Text style = { styles.titleText} >
            Applozic </Text>
			  <Text style = {styles.baseText}>
     			  Demo App </Text>
			  <Text style = {styles.btn} onPress = {this.openChat}>
				    Open Chat List </Text>
        <Text style = {styles.btn} onPress = {this.openChatWithUser}>
    				    One-One Chat </Text>
        <Text style = {styles.btn} onPress = {this.getUnreadCountForUser}>
                            Unread count User </Text>
        <Text style = {styles.btn} onPress = {this.getUnreadCountForChannel}>
                                        Unread count Channel </Text>
        <Text style = {styles.btn} onPress = {this.totalUnreadCount}>
                                Total Unread Count </Text>
        <Text style = {styles.btn} onPress = {this.addMemberToGroup}>
                                            Add Member to group </Text>
        <Text style = {styles.btn} onPress = {this.removeUserFromGroup}>
                                  remove member to group </Text>

        <Text style = {styles.btn} onPress = {this.logoutUser}>
                    LogOut </Text>
		     </View >
            );
        }

        return (
		    <View style ={styles.container}>
            <ScrollView>
              <Text style = {styles.titleText}>
                 Applozic </Text>
			        <Text style = {styles.baseText}>
                 Demo App < /Text>
              <TextInput style ={styles.inputText}
                 keyboardType = "default"
                 placeholder = "UserId"
                 maxLength = {25}
                 underlineColorAndroid = 'transparent'
                 value = {this.state.userId}
                 onChangeText={userId => this.setState({userId})}/>
              <TextInput type = "email-address"
                 style = {styles.inputText}
                 placeholder = "Email"
                 keyboardType = "email-address"
                 maxLength = {30}
                 underlineColorAndroid = 'transparent'
                 value = { this.state.email}
                 onChangeText = {email => this.setState({email})}/>
              <TextInput style = { styles.inputText}
                 placeholder = "Phone Number"
                 keyboardType = "phone-pad"
                 underlineColorAndroid = 'transparent'
                 maxLength = {10}
                 value = {this.state.phoneNumber}
                 onChangeText = {phoneNumber => this.setState({phoneNumber})}/>
              <TextInput id = "password"
                 type = "password"
                 style = {styles.inputText}
                 maxLength = {25}
                 placeholder = "Password"
                 keyboardType = "default"
                 underlineColorAndroid = 'transparent'
                 value = {this.state.pass_word}
                 secureTextEntry = {true}
                 password = "true"
                 onChangeText = {pass_word => this.setState({pass_word})}/>
              <TextInput id = "displayName"
                 style = {styles.inputText}
                 placeholder = "Display Name"
                 keyboardType = "default"
                 underlineColorAndroid = 'transparent'
                 value = {this.state.displayName}
                 maxLength = {25}
                 onChangeText = {displayName => this.setState({displayName})}/>
              <Button title = {this.state.title}
                 onPress = {this.show}
                 color = "#20B2AA"/>
              </ScrollView>
			  </View>
        );
    }
    //======================== Applozic fucntions ==========================================================

        //Login chat to the users..
        chatLogin() {

            if (this.state.userId.length > 0 && this.state.pass_word.length > 0) {
              ApplozicChat.login({
                    'userId': this.state.userId,
                    'email': this.state.email,
                    'contactNumber': this.state.phoneNumber,
                    'password': this.state.pass_word,
                    'displayName': this.state.displayName
                }, (error, response) => {
                  if(error){
                      console.log("error " + error);
                  }else{
                    this.setState({loggedIn: true, title: 'Loading...'});
                    this.createGroup();
                    console.log("response::" + response);
                  }
                })
            } else {
                this.setState({title: 'Login/SignUp'});
                alert("Please Enter UserId & Password");
             };
        }

        openChat(){
          ApplozicChat.openChat();
        }
        //Launch Chat with clientGroupID : '6543274'
        openChatWithUser(){

          ApplozicChat.openChatWithUser('ak101');
        }

        //Launch Chat with clientGroupID : '6543274'
        openChatWithGroupId(groupId){

              ApplozicChat.openChatWithGroup(groupId , (error,response) =>{
                if(error){
                  //Group launch error
                  console.log(error);
                }else{
                  //group launch successfull
                  console.log(response)
                }
              });
        }

        //Launch Chat with clientGroupID
        openChatWithClientGroupId(clientGroupID){

          ApplozicChat.openChatWithClientGroupId(clientGroupID, (error,response) =>{
            if(error){
              //Group launch error
              console.log(error);
            }else{
              //group launch successfull
              console.log(response)
            }
          });

        }

      logoutUser() {

            ApplozicChat.logoutUser((error, response) => {
              if(error){
                console.log("error :#" + error);
              }else{
                this.setState({
                    userId: '',
                    email: '',
                    phoneNumber: '',
                    pass_word: '',
                    displayName: '',
                    loggedIn: false,
                    title: 'Login/SignUp'
                });
              }

            });
        }

        getUnreadCountForUser() {
            ApplozicChat.getUnreadCountForUser( 'ak102', (error, count) => {
              console.log("count for userId:" + count);
            });
        }

        getUnreadCountForChannel() {

          var requestData = {
                'groupId':7107309, //replace with your groupId
                'clientGroupId': '' //
                  // pass either channelKey or clientGroupId
            };

          ApplozicChat.getUnreadCountForChannel(requestData, (error, count) => {
            if(error){
              console.log("error ::" + error);
            }else{
              console.log("count for requestData ::" + count);
            }
          });

        }

        totalUnreadCount() {
            ApplozicChat.totalUnreadCount((error, totalUnreadCount) => {
              console.log("totalUnreadCount for logged-in user:" + totalUnreadCount);

            });

        }

        isUserLogIn() {
            ApplozicChat.isUserLogIn((response) => {
                this.setState({loggedIn: response});
            })
        }

       createGroup(){

          var groupDetails = {
                'groupName':'React Test3',
                'clientGroupId':'recatNativeCGI',
                'groupMemberList': ['ak101', 'ak102', 'ak103'], // Pass list of user Ids in groupMemberList
                'imageUrl': 'https://www.applozic.com/favicon.ico',
                'type' : 2,    //'type' : 1, //(required) 1:private, 2:public, 5:broadcast,7:GroupofTwo
                'metadata' : {
                    'key1' : 'value1',
                    'key2' : 'value2'
                }
            };
            ApplozicChat.createGroup(groupDetails, (error, response) => {
                if(error){
                    console.log(error)
                }else{
                  console.log(response);
                }
              });
      }

      addMemberToGroup(){

        var requestData = {
              'clientGroupId':'recatNativeCGI',
              'userId': 'ak111', // Pass list of user Ids in groupMemberList
          };

          ApplozicChat.addMemberToGroup(requestData, (error, response) => {
               if(error){
                   console.log(error)
               }else{
                 console.log(response);
               }
             });
     }

     removeUserFromGroup(){

       var requestData = {
             'clientGroupId':'recatNativeCGI',
             'userId': 'ak111', // Pass list of user Ids in groupMemberList
         };

          ApplozicChat.removeUserFromGroup(requestData, (error, response) => {
              if(error){
                  console.log(error)
              }else{
                console.log(response);
              }
            });
    }

    //======================== Applozic fucntions END===================================================

}
const styles = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        backgroundColor: '#4D394B'
    },
    btn: {
        fontSize: 23,
        fontWeight: 'bold',
        color: 'yellow',
        marginTop: 20,
        alignSelf: 'center'
    },
    baseText: {
        fontFamily: 'Cochin',
        color: '#fff',
        marginBottom: 25,
        alignSelf: 'center'
    },
    titleText: {
        fontSize: 25,
        fontWeight: 'bold',
        color: '#fff',
        marginTop: 15,
        alignSelf: 'center'
    },
    inputText: {
        width: 330,
        height: 40,
        backgroundColor: '#fff',
        marginBottom: 6,
        padding: 10,
        fontSize: 20,
        marginLeft: 10,
        marginRight: 10
    }
});

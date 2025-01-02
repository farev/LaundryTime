import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import LaundryRoomList from './screens/LaundryRoomList';
import LaundryRoom from './screens/LaundryRoom';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen 
          name="LaundryRoomList" 
          component={LaundryRoomList}
          options={{ title: 'Laundry Time' }}
        />
        <Stack.Screen 
          name="LaundryRoom" 
          component={LaundryRoom}
          options={({ route }) => ({ title: route.params.roomName })}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
} 
import Foundation
import SwiftUI
struct Album: Identifiable {
    var id = UUID()
    var title: String = ""
    var artist: String = ""
    var genre: String = ""
    var format: String = ""
    var year: Int = 0
    var cover_art: String = ""
}

extension Album {
    static var albums = Array(0...10).map({Album(title: "Album \($0)", artist: "Artist\($0)", genre: "Genre\($0)", format: "Format\($0)", year: $0, cover_art: "default")})
}

private class AlbumsViewModel: ObservableObject {
    @Published var albums: [Album] = Album.albums
    
    func addAlbum(album: Album) {
        albums.append(album)
    }
}

struct AlbumsListView: View {
    @StateObject fileprivate var viewModel = AlbumsViewModel()
    @State private var showingCreateSheet = false
    @State private var showingUpdateSheet = false
    @State private var confirmationShown = false
    @State private var itemToDelete: Album? = nil
    @State private var itemToUpdate: Album = Album()

    var body: some View {
        ZStack {
            VStack {
                Text("My albums").font(.title).bold()
                List {
                    ForEach($viewModel.albums) { $album in
                        AlbumRowView(album: $album)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                        itemToDelete = album
                                        confirmationShown = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                            }
                            .onTapGesture {
                                itemToUpdate = album
                                    showingUpdateSheet.toggle()
                            }
                    }
                }
                .confirmationDialog("Delete item?", isPresented: $confirmationShown) {
                    Button("Confirm Delete", role: .destructive) {
                        if let item = itemToDelete {
                            confirmationShown = false
                            itemToDelete = nil
                            viewModel.albums.removeAll(where: {$0.id == item.id})
                        }
                    }
                }
                .sheet(isPresented: $showingUpdateSheet) {
                    UpdateSheetView(albums: $viewModel.albums, album: $itemToUpdate)
                        .presentationDetents([.medium, .large])
                        .padding()
                        .background(Color(.secondarySystemBackground))
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        showingCreateSheet.toggle()
                    }, label: {
                        Text("Add new album").bold()
                    })
                    .padding()
                    .sheet(isPresented: $showingCreateSheet) {
                        CreateSheetView(albums: $viewModel.albums)
                            .presentationDetents([.medium, .large])
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            
                    }
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
            }
        }
        
    }
}

struct AlbumRowView: View {
    @Binding var album: Album
    
    var body: some View {
        HStack(alignment: .top) {
            Image(album.cover_art)
                .resizable()
                .cornerRadius(10)
                .shadow(radius: 5)
                .aspectRatio(contentMode: .fit)
                .frame(height: 100.0)
            VStack(alignment: .leading) {
                Text(album.title).bold().font(.headline);
                Text(album.artist).font(.subheadline);
                Text(album.genre).font(.subheadline);
                Text(album.format).font(.subheadline);
                Text(String(album.year)).font(.subheadline)
            }
            Spacer()
        }
    }
}

struct CreateSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var genre: String = ""
    @State private var format: String = ""
    @State private var year: Int = 2022
    
    @Binding var albums: [Album]
    
    
    var body: some View {
        VStack() {
            Text("Add a new album")
                .font(.title)
                .bold()
            Form {
            TextField("Album title", text: $title)
            TextField("Artist", text: $artist)
            TextField("Genre", text: $genre)
            TextField("Format", text: $format)
            Picker("Release year", selection: $year) {
                        ForEach(1800...2022, id: \.self) {
                            Text(String($0))
                        }
                    }
            }
            Spacer()
            Button(action: {
                albums.append(Album(title: title, artist: artist, genre: genre, format: format, year: year, cover_art: "default"))
                dismiss()
            }, label: {
                Text("Add").bold()
            })
        }
        Spacer()
    }
}

struct UpdateSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var albums: [Album]
    @Binding var album: Album
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var genre: String = ""
    @State private var format: String = ""
    @State private var year: Int = 2022
    
    var body: some View {
        VStack() {
            Text("Update an album")
                .font(.title)
                .bold()
            Form {
                TextField("Album title", text: $album.title)
                TextField("Artist", text: $album.artist)
                TextField("Genre", text: $album.genre)
                TextField("Format", text: $album.format)
                Picker("Release year", selection: $album.year) {
                        ForEach(1800...2022, id: \.self) {
                            Text(String($0))
                        }
                    }
            }
            Spacer()
            Button(action: {
                if let index = albums.firstIndex(where: {$0.id == album.id}) {
                    albums[index] = album
                }
                dismiss()
            }, label: {
                Text("Save").bold()
            })
        }
        Spacer()
    }
}


struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumsListView()
    }
}

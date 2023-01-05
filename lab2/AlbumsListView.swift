import Foundation
import SwiftUI
import CoreData

struct Album_old: Identifiable {
    var id = UUID()
    var title: String = ""
    var artist: String = ""
    var genre: String = ""
    var format: String = ""
    var year: Int = 0
    var cover_art: String = ""
}

extension Album_old {
    static var albums = Array(0...10).map({Album_old(title: "Album \($0)", artist: "Artist\($0)", genre: "Genre\($0)", format: "Format\($0)", year: $0, cover_art: "default")})
}

private class AlbumsViewModel: ObservableObject {
    @Published var albums: [Album_old] = Album_old.albums
    
    func addAlbum(album: Album_old) {
        albums.append(album)
    }
}

struct AlbumsListView: View {
    @FetchRequest(sortDescriptors: []) var albums: FetchedResults<Album>
    @Environment(\.managedObjectContext) var moc
    @StateObject fileprivate var viewModel = AlbumsViewModel()
    @State private var showingCreateSheet = false
    @State private var showingUpdateSheet = false
    @State private var confirmationShown = false
    @State private var itemToDelete: Album? = nil
    @State private var itemToUpdate: Album = Album()
    
    func deleteAlbum (album: Album) {
        moc.delete(album)
        
        try? moc.save()
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("My albums").font(.title).bold()
                
                List(albums) { album in
                    AlbumRowView(album: album).swipeActions(edge: .trailing) {
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
                .confirmationDialog("Delete item?", isPresented: $confirmationShown) {
                        Button("Confirm Delete", role: .destructive) {
                            if let item = itemToDelete {
                                confirmationShown = false
                                itemToDelete = nil
                                deleteAlbum(album: item)
                            }
                        }
                    }
                .sheet(isPresented: $showingUpdateSheet) {
                    UpdateSheetView(album: $itemToUpdate)
                        .environment(\.managedObjectContext, self.moc)
                        .presentationDetents([.medium, .large])
                        .padding()
                        .background(Color(.secondarySystemBackground))
                }
                Spacer()
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
                        CreateSheetView()
                            .environment(\.managedObjectContext, self.moc)
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
    @ObservedObject var album: Album

    var body: some View {
        HStack(alignment: .top) {
            Image(album.cover_art ?? "default")
                .resizable()
                .cornerRadius(10)
                .shadow(radius: 5)
                .aspectRatio(contentMode: .fit)
                .frame(height: 100.0)
            VStack(alignment: .leading) {
                Text(album.title ?? "unknown title").bold().font(.headline);
                Text(album.artist ?? "unknown artist").font(.subheadline);
                Text(album.genre ?? "unknown genre").font(.subheadline);
                Text(album.format ?? "unknown format").font(.subheadline);
                Text(String(album.year)).font(.subheadline)
            }
            Spacer()
        }
    }
}

struct CreateSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc

    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var genre: String = ""
    @State private var format: String = ""
    @State private var year: Int = 2022


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
                let album = Album(context: moc)
                album.id = UUID()
                album.title = title
                album.artist = artist
                album.genre = genre
                album.format = format
                album.year = Int64(year)
                
                try? moc.save()
                
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
    @Environment(\.managedObjectContext) var moc
    
    @Binding var album: Album
    @State var title: String = ""
    @State var artist: String = ""
    @State var genre: String = ""
    @State var format: String = ""
    @State var year: Int = 2022
    
    var body: some View {
        VStack() {
            Text("Update an album")
                .font(.title)
                .bold()
            Form {
                Section {
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
            }
            .onAppear {
                title = album.title ?? ""
                artist = album.artist ?? ""
                genre = album.genre ?? ""
                format = album.format ?? ""
                year = Int(album.year)
            }
            Spacer()
            Button(action: {
                album.title = title
                album.artist = artist
                album.genre = genre
                album.format = format
                album.year = Int64(year)

                try? moc.save()
                
                dismiss()
            }, label: {
                Text("Save").bold()
            })
        }
        Spacer()
    }
}

struct Previews_ContentView_Previews: PreviewProvider {
    static var dataController = DataController()

        static var previews: some View {
            AlbumsListView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
}

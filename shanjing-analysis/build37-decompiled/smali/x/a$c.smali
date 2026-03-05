.class Lx/a$c;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj0/c;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lx/a;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "c"
.end annotation


# instance fields
.field private final a:Lx/c;


# direct methods
.method private constructor <init>(Lx/c;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lx/a$c;->a:Lx/c;

    return-void
.end method

.method synthetic constructor <init>(Lx/c;Lx/a$a;)V
    .locals 0

    invoke-direct {p0, p1}, Lx/a$c;-><init>(Lx/c;)V

    return-void
.end method


# virtual methods
.method public a(Lj0/c$d;)Lj0/c$c;
    .locals 1

    iget-object v0, p0, Lx/a$c;->a:Lx/c;

    invoke-virtual {v0, p1}, Lx/c;->a(Lj0/c$d;)Lj0/c$c;

    move-result-object p1

    return-object p1
.end method

.method public b(Ljava/lang/String;Ljava/nio/ByteBuffer;Lj0/c$b;)V
    .locals 1

    iget-object v0, p0, Lx/a$c;->a:Lx/c;

    invoke-virtual {v0, p1, p2, p3}, Lx/c;->b(Ljava/lang/String;Ljava/nio/ByteBuffer;Lj0/c$b;)V

    return-void
.end method

.method public synthetic c()Lj0/c$c;
    .locals 1

    invoke-static {p0}, Lj0/b;->a(Lj0/c;)Lj0/c$c;

    move-result-object v0

    return-object v0
.end method

.method public d(Ljava/lang/String;Lj0/c$a;Lj0/c$c;)V
    .locals 1

    iget-object v0, p0, Lx/a$c;->a:Lx/c;

    invoke-virtual {v0, p1, p2, p3}, Lx/c;->d(Ljava/lang/String;Lj0/c$a;Lj0/c$c;)V

    return-void
.end method

.method public e(Ljava/lang/String;Ljava/nio/ByteBuffer;)V
    .locals 2

    iget-object v0, p0, Lx/a$c;->a:Lx/c;

    const/4 v1, 0x0

    invoke-virtual {v0, p1, p2, v1}, Lx/c;->b(Ljava/lang/String;Ljava/nio/ByteBuffer;Lj0/c$b;)V

    return-void
.end method

.method public f(Ljava/lang/String;Lj0/c$a;)V
    .locals 1

    iget-object v0, p0, Lx/a$c;->a:Lx/c;

    invoke-virtual {v0, p1, p2}, Lx/c;->f(Ljava/lang/String;Lj0/c$a;)V

    return-void
.end method
